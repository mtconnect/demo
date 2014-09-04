class App < ActiveRecord::Base
  attr_accessible :name, :url, :description, :location, :logo,
                  :enabled, :app_pictures_attributes 
  validates_presence_of :name, :url, :description, :location, :logo

  has_many :app_pictures
  accepts_nested_attributes_for :app_pictures, allow_destroy: true

  scope :active, lambda { |*obj| where(:enabled => true) }

  mount_uploader :logo, LogoUploader

  def has_app_pictures?
    app_pictures.length > 0
  end

  def calculate_frames
    if app_pictures.length % 2 == 0
      app_pictures.length / 2
    else
      (app_pictures.length / 2) + 1
    end
  end

  def no_of_frames
    has_app_pictures? ? calculate_frames : 0
  end
end
