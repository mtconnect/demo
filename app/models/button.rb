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

class Button < Image
  has_attachment :storage => :file_system, :path_prefix => 'public/pictures',
                 :content_type => :image, :processor => ImageScience,
                 :thumbnails => { :thumb => 'x80' }
  
  validates_as_attachment


  def resize_image_or_thumbnail!(img)
    if parent_id.nil?
      if self.width > 2 * self.height
        geo = [270, ((270.0 / self.width.to_f) * self.height).to_i]
      else
        geo = 'x130'
      end
      
      resize_image(img, geo)
    elsif thumbnail_resize_options
      # We need the thumbnail to have a max height or with. This means constraining
      # the larger of the two dimensions. max-width: 160, max-height: 80.
      #
      # The width can be 2x the height. If the image is more than 2x the height,
      # we need to constrain the width to 160 otherwise we need to constrain the height.
      if self.width > 2 * self.height
        geo = [160, ((160.0 / self.width.to_f) * self.height).to_i]
      else
        geo = 'x80'
      end
      
      resize_image(img, geo)
    end
  end
end
