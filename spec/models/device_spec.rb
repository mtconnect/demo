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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'net/http'
require 'rexml/document'

describe Device do
  before(:each) do
    
  end

  it "should request data from a three axis mill" do
    device = create_device(:url => 'http://localhost:3000/LinuxCNC/current')
    
    xml = File.read("#{RAILS_ROOT}/spec/fixtures/current.xml")
    http_client = mock("http_client")
    Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http_client)
    response = Net::HTTPOK.new(nil, 200, nil)
    response.should_receive(:body).and_return(xml)
    http_client.should_receive(:get).with('/LinuxCNC/current').and_return(response)

    device.get_data
  end

  it "should get data from a three axis mill and give values" do
    device = create_device(:url => 'http://localhost:3000/LinuxCNC/current')

    xml = File.read("#{RAILS_ROOT}/spec/fixtures/current.xml")
    http_client = mock("http_client")
    Net::HTTP.stub!(:new).with('localhost', 3000).and_return(http_client)
    response = Net::HTTPOK.new(nil, 200, nil)
    response.stub!(:body).and_return(xml)
    http_client.stub!(:get).with('/LinuxCNC/current').and_return(response)

    data = device.get_data
    data.should have(18).records

    linears = data.select { |e| e.component == 'Linear' }
    linears.should have(6).records

    actual = linears.select { |e| e.item == 'Position' and e.sub_type == 'ACTUAL' }
    actual.should have(3).records

    actual.first.value.should == '-0.287043'
  end

  end
