# == Schema Information
# Schema version: 20090730001620
#
# Table name: images
#
#  id           :integer         default(0), not null, primary key
#  size         :integer         default(0)
#  content_type :string(255)     default("")
#  filename     :string(255)     default("")
#  height       :integer         default(0)
#  width        :integer         default(0)
#  parent_id    :integer         default(0)
#  thumbnail    :string(255)     default("")
#  type         :string(255)     default("")
#  device_id    :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Picture do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Button.create!(@valid_attributes)
  end
end
