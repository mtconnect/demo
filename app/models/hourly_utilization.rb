class HourlyUtilization < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :device
  attr_accessible :device_id, :hour, :utilization
end
