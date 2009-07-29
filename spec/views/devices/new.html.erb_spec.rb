require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/devices/new.html.erb" do
  include DevicesHelper

  before(:each) do
    assigns[:device] = stub_model(Device,
      :new_record? => true,
      :name => "value for name",
      :url => "value for url",
      :description => "value for description"
    )
  end

  it "renders new device form" do
    render

    response.should have_tag("form[action=?][method=post]", devices_path) do
      with_tag("input#device_name[name=?]", "device[name]")
      with_tag("input#device_url[name=?]", "device[url]")
      with_tag("textarea#device_description[name=?]", "device[description]")
    end
  end
end
