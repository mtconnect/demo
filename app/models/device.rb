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

class Device < ActiveRecord::Base
  has_one :button, :dependent => :destroy
  has_one :picture, :dependent => :destroy

  class DataValue
    attr_reader :component, :component_name, :item, :name, :sub_type, :value
    def initialize(component, component_name, item, name, sub_type, value)
      @component, @component_name, @item, @name, @sub_type, @value =
              component, component_name, item, name, sub_type, value
    end
  end

  def get_data
    dest = URI.parse(self.url)
    client = Net::HTTP.new(dest.host, dest.port)
    response = client.get(dest.path)
    if Net::HTTPOK === response
      document = REXML::Document.new(response.body)
      values = []
      document.each_element('//Events/*|//Samples/*') do |value|
        value_attrs = value.attributes
        comp_attrs = value.parent.parent.attributes
        values << DataValue.new(comp_attrs['component'], comp_attrs['name'], value.name, value_attrs['name'],
                                value_attrs['subType'], value.text)
      end
      values
    else
      nil
    end
  end

  def button=(button)
    if !button.is_a?(Button)
      self[:button] = Button.create(:uploaded_data => button)
    else
      self[:button] = button
    end
  end

  def picture=(picture)
    if !picture.is_a?(Picture)
      self[:picture] = Picture.create(:uploaded_data => picture)
    else
      self[:picture] = picture
    end
  end
end
