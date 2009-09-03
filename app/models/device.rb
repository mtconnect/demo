# == Schema Information
# Schema version: 20090730001620
#
# Table name: devices
#
#  id          :integer         default(0), not null, primary key
#  name        :string(255)     default("")
#  url         :string(255)     default("")
#  description :text            default("")
#  application :boolean
#  created_at  :datetime
#  updated_at  :datetime
#
require 'net/http'
require 'rexml/document'
require 'timeout'

class Device < ActiveRecord::Base
  has_one :button, :dependent => :destroy
  has_one :picture, :dependent => :destroy

  class DataValue
    attr_reader :component, :component_name, :item, :name, :sub_type, :value
    def initialize(component, component_name, item, name, sub_type, value)
      @component, @component_name, @item, @name, @sub_type, @value =
              component, component_name, item, name, sub_type, value
      if @value.length > 20
        @value = "#{@value[0..20]}..."
      end
    end
  end

  class Alarm < DataValue
    attr_reader :code, :state
    def initialize(component, component_name, item, name, sub_type, value,
                   code, state)
      super(component, component_name, item, name, sub_type, value)
      @code, @state = code, state
    end
  end

  def get_data
    dest = URI.parse(self.url)
    client = response = nil

    Timeout::timeout(5) do 
      client = Net::HTTP.new(dest.host, dest.port)
      response = client.get("#{dest.path}/current")
    end
    if Net::HTTPOK === response
      document = REXML::Document.new(response.body)
      values = []
      document.each_element('//Events/*|//Samples/*') do |value|
        value_attrs = value.attributes
        comp_attrs = value.parent.parent.attributes
        if value.name == 'Alarm'
          values << Alarm.new(comp_attrs['component'],
                              comp_attrs['name'],
                              value.name,
                              value_attrs['name'],
                              value_attrs['subType'],
                              value.text,
                              value_attrs['code']
                              value_attrs['state'])
        else
          values << DataValue.new(comp_attrs['component'],
                                  comp_attrs['name'],
                                  value.name,
                                  value_attrs['name'],
                                  value_attrs['subType'],
                                  value.text)
        end
      end
      values
    else
      []
    end

  rescue Timeout::Error
    []
    
  rescue
    []
  end

  def button_file=(button)
    self.button = Button.new(:uploaded_data => button)
  end

  def picture_file=(picture)
    self.picture = Picture.new(:uploaded_data => picture)
  end
end
