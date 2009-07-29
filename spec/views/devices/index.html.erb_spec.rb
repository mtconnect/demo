require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/devices/index.html.erb" do
  include DevicesHelper

  before(:each) do
    assigns[:devices] = [
      stub_model(Device,
        :name => "value for name",
        :url => "value for url",
        :description => "value for description"
      ),
      stub_model(Device,
        :name => "value for name",
        :url => "value for url",
        :description => "value for description"
      )
    ]
  end

  it "renders a list of devices" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for url".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
  end
end
