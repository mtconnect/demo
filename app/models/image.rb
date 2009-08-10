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

class Image < ActiveRecord::Base
  has_attachment :storage => :file_system, :path_prefix => 'public/pictures',
                 :content_type => :image
  validates_as_attachment

  belongs_to :device
  
end
