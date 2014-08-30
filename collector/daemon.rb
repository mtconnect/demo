require 'rubygems'

# Setup a logger for the daemon and it's child threads.
require Rails.root.join("collector/collector")

begin
  collector = Collector.new(Device.logger)

  while true
    begin
      collector.check_for_new_devices
    rescue
      Device.logger.error("Exception caught in collector loop: #{$!.class} #{$!}\n#{$!.backtrace.join("\n")}")
    end

    begin
      collector.update_utilization
    rescue
      Device.logger.error("Exception caught in collector loop: #{$!.class} #{$!}\n#{$!.backtrace.join("\n")}")
    end
    
    ActiveRecord::Base.connection_pool.release_connection
    sleep 10
  end

rescue Exception => e
  Device.logger.fatal("Insight daemon fatal exception: #{e}\n#{e.backtrace.join("\n")}")
  raise e
ensure
  Device.logger.close
end
