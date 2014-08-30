require 'net/http'
require 'set'

require Rails.root.join("collector/long_pull")

# Fetches data from MTConnect agent and
# pushses to SystemsInsights app
class Collector 
  attr_reader :devices, :logger
  @@update_mutex = Monitor.new
  @@selector = "path=" + CGI.escape('//DataItem[@category="CONDITION"]|' + 
                                  '//DataItem[@type="CONTROLLER_MODE"or@type="EXECUTION"or@type="ASSET_CHANGED"]')
  

  def initialize(logr = nil)
    @logger = logr || Logger.new(STDOUT)
    @threads = Set.new
  end

  def http_client(device)
    dest = URI.parse(device.url)
    path = dest.path
    path += '/' unless path[-1] == ?/
    [Net::HTTP.new(dest.host, dest.port), path]
  end

  # Returns the next sequence number from device.
  def get_current(device, selector)
    client, path = http_client(device)
    resp = client.get("#{path}current?#{selector}")
    xml = resp.body
            
    # Handle update returns next...
    nxt = nil
    @@update_mutex.synchronize do 
      nxt = device.handle_update(xml)
    end
    nxt
    
  rescue
    logger.info "#{device.id} - Error during get_current: #{$!}"
    raise
    
  ensure
    if client
      client.finish rescue puts "#{device.id} - client finish failed: #{$!}"
    end
  end

  def pull_thread(device)
    puts "Starting pull thread for #{device.id}"
    @threads.add(device.id)
    
    while true
      begin
        # Reload the data in the device.
        logger.info "#{device.id} - Connecting to device #{device.url}"
        device.reload        
        return unless device.enabled

        nxt = get_current(device, @@selector)
        logger.info "Will start at #{nxt}"

        client, path = http_client(device)
        path << "sample?#{@@selector}&from=#{nxt}&frequency=1000&count=1000"

        puller = LongPull.new(client)
        
        logger.info "Starting long pull for #{device.id} - #{path}"
        
        old_url = device.url
        puller.long_pull(path) do |xml|
          ActiveRecord::Base.connection_pool.release_connection
          @@update_mutex.synchronize do
            device.reload
            return if !device.enabled
            break if device.url != old_url

            device.handle_update(xml)
          end
          ActiveRecord::Base.connection_pool.release_connection
        end

      rescue ActiveRecord::RecordNotFound
        logger.warn "#{device.id} - Device has been deleted"
        return
        
      rescue Exception        
        # Just keep retrying. This is usually indicative of a connection problem.
        # Should clean up and only retry connection errors.
        logger.warn "#{device.id} - Could not connect to #{device.url}: #{$!}"

      ensure
        device.disconnected
        if client
          client.finish rescue logger.warn "#{device.id} - (long_pull) client finish failed: #{$!}"
        end
        ActiveRecord::Base.connection_pool.release_connection
        sleep 10
      end
    end
    
  ensure
    logger.warn "#{device.id} - Collector thread exiting"
    @threads.delete(device.id)
  end

  def threadify(id)
    device = Device.find(id)
    Thread.new { pull_thread(device) }
  rescue Exception => e
    logger.error("Unable to start thread for device \##{id}: #{e}\n#{e.backtrace.join("\n")}")
  end

  def new_devices
    Set.new(Device.active.map(&:id)) - @threads
  end

  def check_for_new_devices    
    new_devices.each do |id|
      threadify(id)
    end
  end
  alias :start_long_pull :check_for_new_devices
  
  def update_utilization
    Device.active.each do |device|
      device.update_daily_utilization
      device.update_hourly_utilization
    end
  end
end


