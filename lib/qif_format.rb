#!/usr/bin/env ruby

require 'rexml/document'


class String
  def uncapitalize 
    self[0, 1].downcase + self[1..-1]
  end
end

class QualityGenerator

  def initialize(doc)
    @doc = doc
    @qif = doc.elements['//QIFDocument']
    @devices = {}
    @product = nil
  end  

  Device = Struct.new(:accuracy, :description, :id, :manufacturer, :name, :resolution, :serialNumber, :type)  
  
  def parse_devices
    @qif.each_element("MeasurementResources/MeasurementDevices/*") do |device|
      attrs = {type: device.name, id: device.attributes['id']}
      device.each_element_with_text do |f|
        text = f.text.strip
        f.each_element_with_text { |t| text << t.text }
        attrs[f.name.uncapitalize.to_sym] = text
      end  
      device = Device.new(*attrs.keys.sort.map { |k| attrs[k] })
      @devices[device.id] = device
    end
  end

  class Product    
    attr_reader :root, :parts
    
    Part = Struct.new(:id, :name)

    def initialize(root, parts)
      @root = root
      @parts = parts
    end
  end

  def parse_product
    root = nil
    parts = []
    @qif.each_element('Product/*') do |e|
      case e.name
      when 'PartSet'
        e.each_element('Part') do |part|
          parts << Product::Part.new(part.attributes['id'], part.elements['Name'].text)
        end
        
      when 'RootPart'
        root = e.elements['Id'].text
      end
      
      @product = Product.new(root, parts)
    end    
  end
  
  module Characteristic
    Definition = Struct.new(:id, :name, :min, :max, :limit)
    Nominal = Struct.new(:id, :definition, :target, :mode)
    Item = Struct.new(:id, :description, :name, :devices, :nominal)
  end
  
  def parse_characteristics
    # definitions
    @definitions = {}      
    @qif.each_element('Characteristics/CharacteristicDefinitions/*') do |c|
      id = c.attributes['id']
      name = c.elements['Name'].text
      min = c.elements['Tolerance/MinValue'].text
      max = c.elements['Tolerance/MaxValue'].text
      limit = c.elements['Tolerance/DefinedAsLimit'].text        
      @definitions[id] = Characteristic::Definition.new(id, name, min, max, limit)        
    end
    
    @nominals = {}
    @qif.each_element('Characteristics/CharacteristicNominals/*') do |c|
      id = c.attributes['id']
      def_id = c.elements['CharacteristicDefinitionId'].text
      target = c.elements['TargetValue'].text
      mode = c.elements['AnalysisMode'].text
      
      definition = @definitions[def_id]
      if definition
        @nominals[id] = Characteristic::Nominal.new(id, definition, target, mode)        
      else
        puts "Cannot find characteristic definition for: #{def_id}"
      end
    end
    
    @items = {}
    @qif.each_element('Characteristics/CharacteristicItems/*') do |c|
      id = c.attributes['id']
      description = c.elements['Description'].text
      name = c.elements['Name'].text
      devices = c.get_elements('MeasurementDeviceIds/*').map { |d| d.text }
      nom_id = c.elements['CharacteristicNominalId'].text
      nominal = @nominals[nom_id]
      if nominal
        @items[id] = Characteristic::Item.new(id, description, name, devices, nominal)
      else
        puts "Cannot find characteristic nominal for: #{nom_id}"
      end
    end    
  end
  
  class MeasurementResult
    attr_reader :id, :actuals, :status
    
    CharacteristicActual = Struct.new(:id, :item, :status, :value)
    def initialize(id, actuals, status)
      @id, @actuals, @status = id, actuals, status
    end
  end  
  
  def parse_results
    @results  = {}
    @actuals = {}
    @qif.each_element('MeasurementsResults/MeasurementResults') do |r|
      actuals = r.get_elements('MeasuredCharacteristics/CharacteristicActuals/*').map do |act|
        id = act.attributes['id']
        status = act.elements['Status/CharacteristicStatusEnum'].text
        item_id = act.elements['CharacteristicItemId'].text
        value = act.elements['Value'].text        
        @actuals[id] = MeasurementResult::CharacteristicActual.new(id, @items[item_id], status, value)
      end
      
      id = r.attributes['id']      
      status = r.elements['InspectionStatus/InspectionStatusEnum'].text
      @results[id] = MeasurementResult.new(id, actuals, status)
    end
  end
  
  class StudyResult
    attr_reader :item, :groups, :status, :stats
    
    Group = Struct.new(:id, :actuals)
    
    def initialize(item, groups, status, stats)
      @item, @groups, @status, @stats = item, groups, status, stats
    end
  end
  
  def parse_statistics
    @studies = []
    @qif.each_element('Statistics/StatisticalStudiesResults/' +
                      'CapabilityStudyResults/CharacteristicsStats/' + 
                      'DistanceBetweenCharacteristicStats') do |s|
      results = s.get_elements('Subgroup').map do |e|
        StudyResult::Group.new(e.attributes['id'], e.get_elements('ActualIds/Ids/Id').map { |i| @actuals[i.text] })
      end
      
      item = results.first.actuals.first.item
      status = s.elements['Status/StatsEvalStatusEnum'].text
      
      stats = Hash[*s.get_elements('ValueStats/*').map { |e| [e.name, e.text] }.flatten]
      @studies << StudyResult.new(item, results, status, stats)
    end
  end
  
  def generate_table(file)
    doc = REXML::Document.new
    
    # Header
    html = doc.add_element('html')
    head = html.add_element('head')
    head.add_element('link', 'rel' => 'stylesheet', 'type' => 'text/css', 'href' => '/qif.css')
    body = html.add_element('body')
    
    #body
    table = body.add_element 'table'    
    
    header = ['Characteristic ID', 'LTL', 'Target', 'UTL']
    columns = []
    stat_headings = []
    measures = []
    measures_header = []

    first = true
    @studies.each do |study|      
      column = []
      item = study.item
      
      column << item.description
      column << item.nominal.definition.min
      column << item.nominal.target
      column << item.nominal.definition.max
      
      header << 'Statistical Summary' if first
      column << ''
      
      if first
        stat_headings = study.stats.keys.sort
        header.concat stat_headings
      end
      stat_headings.each do |h|
        column << study.stats[h]
      end

      columns << column

      header << 'Part Measurements' if first
      column << ''

      column = []
      study.groups.each do |group|
        measures_header << group.id if first
        column << group.actuals.first.value
      end

      measures << column

      first = false
    end        
    
    columns.unshift header
    rows = columns.first.zip(*columns[1..-1])
    
    thead = table.add_element('thead')
    row = thead.add_element 'tr'
    row.add_element('th').add_text('Part ID')
    row.add_element('th').add_text(@product.parts.first.name)
    (columns.size - 2).times { row.add_element('th') }
    
    row = rows.shift
    tr = thead.add_element 'tr'
    row.each do |e|
      tr.add_element('th').add_text(e)
    end
    
    tbody = table.add_element('tbody')
    rows.each do |row|
      tr = tbody.add_element 'tr'
      cls = { 'class' => 'bold' }
      row.each do |e|
        tr.add_element('td', cls).add_text(e)
        cls = nil
      end
    end

    measures.unshift measures_header
    rows = measures.first.zip(*measures[1..-1])
    rows.each do |row|
      tr = tbody.add_element 'tr'
      cls = { 'class' => 'bold' }
      row.each do |e|
        tr.add_element('td', cls).add_text(e)
        cls = { 'class' => 'measurement'}
      end
    end

    File.open(file, 'w') { |f| f.write html.to_s }
  end

  def parse
    parse_devices
    parse_product
    parse_characteristics
    parse_results
    parse_statistics
  end
end
