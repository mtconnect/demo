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

class Device < ActiveRecord::Base
  has_one :button, :dependent => :destroy
  has_one :picture, :dependent => :destroy
end
