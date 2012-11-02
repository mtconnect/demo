#!/usr/bin/env ruby

require 'rexml/document'
require 'open-uri'

class FaiGenerator
  STYLE_LINK = false

  def initialize(doc)
    @doc = doc
  end
  
  def add_cell(row, label, value = 'N/A', cols = 1, rows = 1)
    cell = REXML::Element.new('td', row)
    cell.add_attribute('rowspan', rows) if rows > 1
    cell.add_attribute('colspan', cols) if cols > 1


    lbl = REXML::Element.new('label', cell)
    lbl.text = label
    lbl.add_attribute('class', 'cell')
    REXML::Element.new('span', cell).text = value  
  end

  def add_checkboxes(row, labels, values, value, cols = 1, rows = 1)
    cell = REXML::Element.new('td', row)
    cell.add_attribute('rowspan', rows) if rows > 1
    cell.add_attribute('colspan', cols) if cols > 1

    labels.zip(values).each do |label, val|
      lbl = REXML::Element.new('label', cell)
      id = label.downcase.gsub(/ /, '_')
      lbl.add_attributes('for' => id, 'class' => 'check')
      lbl.text = label

      check = REXML::Element.new('input', cell)
      check.add_attributes('type'=> "checkbox", 'name' => id, 'value' => val, 'id' => id, 'disabled' => 'true')
      check.add_attribute('checked', 'yes') if val == value
      REXML::Element.new('br', cell)
    end
  end

  def add_text(row, *fields)
    cls = fields.shift
    fields.each do |text|
      cell = REXML::Element.new('td', row)
      cell.add_attribute('class', cls)
      cell.text = text
    end
  end

  def chase_id(element, path, target = nil)
    if element and (ele = element.elements[path])
      id = ele.text
      @doc.elements["//#{target}[@id=\"#{id}\"]"]
    else
      puts "Cannot find #{path} for #{element.inspect}"
      nil
    end
  end
  
  def get_text(element, path, att = nil)
    if element and (ele = element.elements[path])
      text = ele.text
      if att and (v = ele.attributes[att])
        text = "#{text} #{v}"
      end
      text
    else
      puts "Cannot find #{path} for #{element.inspect}"
      "N/A"
    end
  end
  
  def get_actuals
    return @actuals if @actuals
    
    @actuals = {}
    @doc.each_element('//CharacteristicActuals/*') do |actual|
      if nom = actual.elements['.//NominalId']
        @actuals[nom.text] = actual
      end
    end
  end
  
  def form1(table)
    row = REXML::Element.new('tr', table)
    add_cell(row, '1. Part Number:', @modelNumber)
    add_cell(row, '2. Part Name:', @partName)
    add_cell(row, '3. Serial Number:', @serial)
    add_cell(row, '4. FAI Report Number:', @reportNumber)

    row = REXML::Element.new('tr', table)
    add_cell(row, '5. Part Revision Level:', get_text(@definition, './/PartRevisionLevel'))
    add_cell(row, '6. Drawing Number:', get_text(@geometry, './/DrawingNumber'))
    add_cell(row, '7. Drawing Revision Level:', get_text(@geometry, './/DrawingRevisionLevel'))
    add_cell(row, '8. Additional Changes:', get_text(@geometry, './/AdditionalChanges'))

    row = REXML::Element.new('tr', table)
    add_cell(row, '9. Manufacturing Process Reference:', get_text(@trace, './/ManufacturingProcessReference'))
    add_cell(row, '10. Organization Name:', get_text(@trace, './/InspectingOrganization/Name'))
    add_cell(row, '11. Supplier Code:', get_text(@trace, './/SupplierCode'))
    add_cell(row, '12. P.O. Number:', get_text(@trace, './/PurchaseOrderNumber'))

    mode = get_text(@trace, './/InspectionMode')
    row = REXML::Element.new('tr', table)
    add_checkboxes(row, ['13. Detail FAI', 'Assembly FAI'], ['DETAIL', 'ASSEMBLY'], get_text(@trace, './/InspectionScope'), 1, 2)
    add_checkboxes(row, ['14. Full FAI', 'Partial FAI'], ['FAI_Full', 'FAI_Partial'], mode)
    add_cell(row, 'Baseline Part Number including revision level', '', 2)

    row = REXML::Element.new('tr', table)
    if mode == 'FAI_Partial'
      text = get_text(@trace, './/ReasonForPartialInspection') 
    else
      text = 'N/A'
    end
    add_cell(row, 'Reason for partial FAI', text, 3, 1)

    row = REXML::Element.new('tr', table)  
    add_cell(row, '12. Prepared by', get_text(@trace, './/ReportPreparer/Name'), 2)
    add_cell(row, '13. Date', get_text(@trace, './/ReportPreparationDate'), 2)
  end
  
  def form3(table)
    row = REXML::Element.new('tr', table)
    add_cell(row, '1. Part Number:', @modelNumber, 4)
    add_cell(row, '2. Part Name:', @partName, 3)
    add_cell(row, '3. Serial Number:', @serial)
    add_cell(row, '4. FAI Report Number:', @reportNumber)

    row = REXML::Element.new('tr', table)
    cell = REXML::Element.new('td', row)
    cell.add_attributes('colspan' => '4', 'class' => 'centered')
    cell.text = 'Characteristic Accountability'
    cell = REXML::Element.new('td', row)
    cell.add_attributes('colspan' => '3', 'class' => 'centered')
    cell.text = 'Inspection Test Results'
    cell = REXML::Element.new('td', row)
    cell.add_attribute('colspan', '2')

    row = REXML::Element.new('tr', table)
    add_text(row, 'bold', '5. Char No.', '6. Reference Location', '7. Characteristic Designator', '8. Requirement', 
            '9. Results', '10. Designed Tooling', '11. Non-Conformance Number')
    cell = REXML::Element.new('td', row)
    cell.add_attributes('class' => 'bold', 'colspan' => '2')
    cell.text = '14. Insert Columns, etc. as required by Organization or Customer'  
    
    @doc.each_element('//CharacteristicInstances/*') do |char|
      row = REXML::Element.new('tr', table)
  
      fields = [get_text(char, './/Name')] # 5
      if char.elements['.//LocationOnDrawing']
        fields << char.elements['.//LocationOnDrawing'].elements.map { |e| e.text }.join(' - ') # 6
      else
        fields << 'N/A'
      end
      fields << get_text(char, './/Criticality') # 7
  
      # 8
      act = chase_id(char, './/ActualId', 'CharacteristicActuals//')
      nom = chase_id(act, './/NominalId', 'CharacteristicNominals//')
      nom = chase_id(char, './/NominalId', 'CharacteristicNominals//') unless nom
      if act.nil? and nom
        get_actuals
        act = @actuals[nom.attributes['id']] if nom
      end
      dfn = chase_id(nom, './/DefinitionId', 'CharacteristicDefinitions//')
      
      if dfn and dfn.elements['.//MinValue']
        min = get_text(dfn, './/MinValue/*')
        max = get_text(dfn, './/MaxValue/*')
      else
        puts "*** getting min and max from nominal"
        min = get_text(nom, './/MinValue', 'unitName')
        max = get_text(nom, './/MaxValue', 'unitName')        
      end
      
      if (nom and nom.name)
        fields << "#{nom.name.sub(/CharacteristicNominal/, '')} Target: #{get_text(nom, './/TargetValue')} (#{min},#{max})"
      else
        fields << "N/A"
      end
  
      # 9
      if act
        val = act.elements['.//ActualValue']
        if val.has_elements?
          val = val.elements[1]
          if (val)
            fields << "#{get_text(act, './/CoordinateType').capitalize} #{val.name} #{val.text}"
          else
            fields << "N/A"
          end
        else
          fields << "#{val.text} #{val.attributes['unitName']}"
        end
      end
  
      # 10
      trace = chase_id(char, './/TraceabilityId', 'Traceability') || @trace
      device = chase_id(trace, './/FixtureId|.//MeasurementDeviceId/Id', 'MeasurementDevices//*')
        
      fields << get_text(device, './/Name')
      fields << 'N/A' # 11. non-conformance
  
      add_text(row, '', *fields)
      cell = REXML::Element.new('td', row)
      cell.add_attribute('colspan', '2')
      cell.text = 'N/A'
    end

    row = REXML::Element.new('tr', table)
    add_cell(row, '12. Prepared by', get_text(@trace, './/ReportPreparer/Name'), 7)
    add_cell(row, '13. Date', get_text(@trace, './/ReportPreparationDate'), 3)
  end

  def generate
    root = REXML::Document.new
    html = REXML::Element.new('html', root)
    head = REXML::Element.new('head', html)

    style = REXML::Element.new('link', head)
    style.add_attributes('rel' => 'stylesheet', 'type' => 'text/css', 'href' => '/fai/fai.css')

    body = REXML::Element.new('body', html)
    
    @doc.each_element('//PartInstance') do |pi|
      @instance = pi
      
      @trace = chase_id(@instance, './/PartTraceability', 'Traceability')
      @definition = chase_id(@instance, './/PartDefinitionId', 'PartDefinition')
      @geometry = chase_id(@definition, './/PartGeometryDefinitionId', 'PartGeometryDefinition')

      @modelNumber = get_text(@definition, './/PartModelNumber')
      @partName = get_text(@definition, './/PartName')
      @serial = get_text(@instance,'.//PartSerialNumber')
      @reportNumber = get_text(@trace, './/ReportNumber')
      
      h1 = REXML::Element.new('h1', body)  
      h1.text = 'Form 1'  
      table = REXML::Element.new('table', body)
      form1(table)

      # Form 3
      h1 = REXML::Element.new('h1', body)    
      h1.text = 'Form 3'
      table = REXML::Element.new('table', body)
      form3(table)
    end

    root.to_s
  end
end

if __FILE__ == $0
  gen = FaiGenerator.new(REXML::Document.new(File.read(ARGV[0])))
  File.open(ARGV[1], 'w') { |f| f.write gen.generate }
end
