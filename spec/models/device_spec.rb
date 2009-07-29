require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Device do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :url => "value for url",
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    Device.create!(@valid_attributes)
  end
end
