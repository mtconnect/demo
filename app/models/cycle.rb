class Cycle < ActiveRecord::Base
  belongs_to :device
  attr_accessible :device_id, :started, :stopped
  
  def duration
    (self.stopped || Time.now.to_i) - self.started
  end      
  
  def bounded_duration(lower, upper)
    # Check if we are outside the range
    unless self.started > upper or (self.stopped and self.stopped < lower)
      start = self.started < lower ? lower : self.started

      stop = self.stopped || Time.now.to_i
      stop = stop > upper ? upper : stop
    
      stop - start
    else
      0
    end
  end
end
