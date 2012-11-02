class Alarm < ActiveRecord::Base
  belongs_to :device
  attr_accessible :device_id, :time, :cleared, :code, :description, :severity, :alarm_type, :data_item_id
  
  def formatted_time
    self.time.localtime.strftime('%H:%M:%S')
  end

  def cleared_time
    self.cleared.nil? ? 'Active' : self.cleared.localtime.strftime('%H:%M:%S')
  end

  def severity_class
    self.severity == 'Fault' ? 'fault' : 'warning'
  end
end