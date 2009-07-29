require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/devices/show.html.erb" do
  include DevicesHelper
  before(:each) do
    assigns[:device] = @device = stub_model(Device,
      :name => "value for name",
      :url => "value for url",
      :description => "value for description"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ url/)
    response.should have_text(/value\ for\ description/)
  end
end
