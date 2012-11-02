class AppPicture < ActiveRecord::Base
  attr_accessible :file
  belongs_to :app

  mount_uploader :file, FileUploader 
end
