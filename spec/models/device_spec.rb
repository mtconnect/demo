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
#  image_file  :string(255)     default("")
#  logo_file   :string(255)     default("")
#  created_at  :datetime
#  updated_at  :datetime
#

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
