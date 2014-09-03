class Device < ActiveRecord::Base
  attr_accessible :name, :url, :enabled, :on_time, :off_time, 
                  :description, :location, :logo, :picture, :in_cycle,
                  :logo_cache, :picture_cache, :daily_utilization,
                  :cutting_tool, :quality_report,
                  :has_utilization
                  
  attr_reader :cutting_tool_doc
  
  mount_uploader :logo, LogoUploader
  mount_uploader :picture, PictureUploader
  validates_presence_of :name, :on_time, :off_time,
                       :description, :location, :logo                                           

  has_many :alarms, :dependent => :destroy, :class_name => '::Alarm'
  has_many :cycles, :dependent => :destroy
  has_many :hourly_utilizations, :dependent => :destroy
  
  scope :active, lambda { |*obj| where(:enabled => true) }
  scope :url_not_null, lambda { |*obj| where.not(:url => nil) }
  scope :with_url, lambda { |*obj| where.not(:url => "").merge(self.url_not_null) }

  class DataValue
    attr_reader :component, :component_name, :item, :name, :sub_type, :value 
    def initialize(component, component_name, item, name, sub_type, value)
      @component, @component_name, @item, @name, @sub_type, @value=
        component, component_name, item, name, sub_type, value
      @value.strip!
      if @value && @value.length > 20
        @value = "#{@value[0..20]}..."
      end
      if @value =~ /^[0-9\.]+$/
        @value = @value.to_f.to_s
      end
    end
  end

  class Alarm < DataValue
    attr_reader :code, :state
    def initialize(component, component_name, item, name, sub_type, value,
        code, state)
      super(component, component_name, item, name, sub_type, value)
      @code, @state = code, state
    end
  end

  class Condition < DataValue
    attr_reader :value_type
    def initialize(component, component_name, item, name, sub_type, value,
        value_type)
      super(component, component_name, item, name, sub_type, value)
      @value_type = value_type
    end
  end
  
  class Component 
    attr_accessor :name, :nativeName, :type, :values
    def initialize(name, nativeName, type)
      @name, @nativeName, @type = name, nativeName, type
      @values = []
    end
  end
  
  def get_data
    return [] unless has_url?

    @asset = nil
    dest = URI.parse(self.url)
    client = response = nil
    Timeout::timeout(3) do
      Net::HTTP.start(dest.host, dest.port) do |client|
        response = client.get("#{dest.path}/current")
      end
    end
    if Net::HTTPOK === response
      document = REXML::Document.new(response.body)
      components = []
      @version == "1.0"
      document.each_element('//Header') do |head|
        if head.attributes['version'] == "1.1"
          @version = "1.1"
        end
      end
      document.each_element('//ComponentStream') do |component|
        comp_attrs = component.attributes
        comp = Component.new(comp_attrs['name'] || comp_attrs['componentId'], 
                             comp_attrs['nativeName'], 
                             comp_attrs['component'])
        # Special handling for Spindles
        if comp.type == 'Rotary'
          component.each_element_with_text('SPINDLE', 0, 'Events/RotaryMode') { |v| comp.type = 'Spindle' }
        end
        components << comp
        component.each_element('Events/*|Samples/*|Condition/*') do |value|
          value_attrs = value.attributes
          if value.name == 'Alarm'
            comp.values << Alarm.new(comp_attrs['component'], comp_attrs['name'], value.name, value_attrs['name'], value_attrs['subType'], value.text || "", value_attrs['code'], value_attrs['state'])
          elsif value.parent.name == 'Condition' 
            if value.name != 'Normal' and value.name != 'Unavailable' and value.text != 'UNAVAILABLE'
              comp.values << Condition.new(comp_attrs['component'], comp_attrs['name'], value.name, value_attrs['name'], value_attrs['subType'], value.text || "", value_attrs['type'])
            end
          elsif value.text and value.text != 'UNAVAILABLE' and !value.text.empty?
            comp.values << DataValue.new(comp_attrs['component'], comp_attrs['name'], value.name, value_attrs['name'], value_attrs['subType'], value.text || "")
          else
            next
          end
        end
      end
      
      result = Hash.new { |h, v| h[v] = [] }
      components.delete_if { |c| c.values.empty? }
      components.each { |c| result[c.type] << c }
      result.each { |k, v| v.sort_by { |c| c.name} }
    else
      logger.error "Response from server #{response}"
      []
    end

  rescue Timeout::Error
    logger.error "Request to #{self.url} timed out"
    []

  rescue Errno::ECONNREFUSED, SocketError
    logger.error "Could not connect to #{self.url}"
    []
  
  rescue
    logger.error "#{$!.class}: Unexpected error: #{$!}"
    logger.error $!.backtrace.join("\n")
    []
  end 
  
  def get_asset(asset_id)
    dest = URI.parse(self.url)
    response = asset = nil
    begin
      Timeout::timeout(5) do 
        Net::HTTP.start(dest.host, dest.port) do |client|
          response = client.get("/asset/#{asset_id}")
        end
      end  
      if Net::HTTPOK === response
        asset = REXML::Document.new(response.body)
        asset = nil if asset.root.name != "MTConnectAssets"
      end
    rescue Timeout::Error
    rescue Exception
      logger.error "Error getting asset: #{$!}"
    end
    asset
  end
  
  def has_cutting_tool?
    if defined? @has_cutting_tool
      return @has_cutting_tool
    end
    
    if self.cutting_tool and !self.cutting_tool.empty?
      @cutting_tool_doc = get_asset(self.cutting_tool)
      if  @cutting_tool_doc and @cutting_tool_doc.elements['//CuttingTool']
        @has_cutting_tool = true
      else
        self.update_attributes(:cutting_tool => nil)
        @has_cutting_tool = false
      end
    else
      @has_cutting_tool = false
    end
  end
  
  def has_quality_report?
    self.quality_report? and
      File.exists?("#{Rails.root}/public/quality/#{id}/#{quality_report}.html")
  end
  
  def format_quality_report(asset_id)
    file_name = "/quality/#{id}/#{asset_id}.html"
    full_path = "#{Rails.root}/public/#{file_name}"
    if File.exists?(full_path)
      mtime = File.stat(full_path).mtime.to_i
      "#{file_name}?#{mtime}"
    else
      ""
    end
  end
  
  def generate_quality_report(asset_id, doc = nil)
    file_name = "#{Rails.root}/public/quality/#{id}/#{asset_id}.html"
    logger.info "#{id} - Generating quality report for #{asset_id} to #{file_name}"
    
    Dir.mkdir(File.dirname(file_name)) unless File.exists?(File.dirname(file_name))
    
    doc = get_asset(asset_id) unless doc
    gen = QualityGenerator.new(doc)
    gen.parse
    gen.generate_table(file_name)

  rescue
    logger.error "Parse and generate of quality report failed #{self.id} #{asset_id}: #{$!}"
    logger.error $!.backtrace.join("\n")
  end

  def has_url?
    self.url and !self.url.empty?
  end
  
  def has_asset?
    self.cutting_tool? or self.quality_report?
  end
  
  def show_utilization?
    (self.has_url? and self.has_utilization?) or !has_asset?
  end

  def handle_update(xml)
    document = REXML::Document.new(xml)
    # puts document
    # Check for Execution and ControllerMode      
      
    # Do some initializations only the first time through. 
    unless defined?(@execution); @execution = 'UNAVAILABLE'; end
    unless defined?(@mode); @mode = 'UNAVAILABLE'; end
    
    document.each_element('//Execution|//ControllerMode|//Warning|//Fault|//Normal|//AssetChanged') do |element|      
      case element.name
      when 'ControllerMode'
        @mode = element.text
        logger.info "#{id} - Mode = #{@mode}"
        unless self.has_utilization or @mode == 'UNAVAILABLE'
          self.update_attributes(:has_utilization => true)
        end
        
      when 'Execution'
        @execution = element.text
        logger.info "#{id} - Execution = #{@execution}"
        unless self.has_utilization or @execution == 'UNAVAILABLE'
          self.update_attributes(:has_utilization => true)
        end
        
      when 'Warning', 'Fault'
        timestamp = DateTime.parse(element.attributes['timestamp'])
        
        # Add condition to list for device at timestamp. Only add the text and time.
        # Look for duplicate
        old = alarms.where('time = ? and code = ?', timestamp, 
                          element.attributes['nativeCode'])
        if old.empty?
          logger.info "#{id} - Creating a new alarm: #{element}"
          ::Alarm.create!(device_id: id, 
                        time: timestamp, 
                        alarm_type: element.attributes['type'],
                        severity: element.name,
                        code: element.attributes['nativeCode'],
                        data_item_id: element.attributes['dataItemId'],
                        description: element.text)
        else
          logger.info "#{id} - Skipping alarm #{element}"
        end
        
      when 'Normal'        
        logger.info "#{id} - Received a normal - #{element}"
        code = element.attributes['nativeCode']
        if code.nil? or code.empty?
          old = alarms.where('data_item_id = ? and cleared is NULL', element.attributes['dataItemId'])
        else
          old = alarms.where('data_item_id = ? and code = ? and cleared is NULL', element.attributes['dataItemId'],
                             code)          
        end
        timestamp = DateTime.parse(element.attributes['timestamp'])
        old.each do |alarm|          
          alarm.update_attributes(:cleared => timestamp)
          logger.info "#{id} - Cleared alarm: #{alarm.inspect}"
        end
        
      when 'AssetChanged'
        if element.text != 'UNAVAILABLE'
          begin
            asset_type = element.attributes['assetType']
            logger.info "#{id} - Got asset #{asset_type}"
            gen = false
            asset_id = element.text
            if asset_type == 'CuttingTool'
              self.update_attributes(:cutting_tool => asset_id)
            elsif asset_type == 'Quality'
              Thread.new { 
                generate_quality_report(asset_id)
                self.update_attributes(:quality_report => asset_id)
                ActiveRecord::Base.connection_pool.release_connection                
              }
            end
          rescue
            logger.error "#{id} - AssetChanged: #{$!}"
          end
        end          
      end
    
      if @mode == 'AUTOMATIC' and @execution == 'ACTIVE'
        self.update_attributes(:in_cycle => true)
      else
        self.update_attributes(:in_cycle => false)
      end      
    end
    
    check_cycle
        
    document.elements['//Header'].attributes['nextSequence'].to_i
  end
  
  def check_cycle
    #storing things to database
    logger.info "#{id} - Checking cycle at #{Time.now}: In cycle: #{self.in_cycle}"
    
    current_cycle = cycles.where('stopped is NULL').first
    if current_cycle.nil? and self.in_cycle
      logger.info "#{id} - Creating new cycle"
      Cycle.create!(device_id: id, started: Time.now.to_i)
    elsif current_cycle and !self.in_cycle
      logger.info "#{id} - Stopping cycle"
      current_cycle.update_attributes(:stopped => Time.now.to_i)
    end
  end
  
  def disconnected
    current_cycle = cycles.where('stopped is NULL').first
    if current_cycle
      current_cycle.update_attributes(:stopped => Time.now.to_i)
    end      
  end
  
  def state
    in_cycle ? "Active" : "Down"
  end

  def state_css_class
    in_cycle ? "alert-success" : "alert-danger"
  end

  def elapsed_daily_utilization
    self.daily_utilization ? self.daily_utilization : 0
  end
  
  def elapsed_hourly_utilization
    grouped_utilization = {}
    last = nil
    hourly_utilizations.sort_by(&:hour).each do |util|
      grouped_utilization[util.hour] = util.utilization
      last = util.hour
    end
    if last and grouped_utilization.length < 5
      (last + 1).upto(last + (5 - grouped_utilization.length)) do |h|
        grouped_utilization[h] = 0
      end
      p grouped_utilization
    end
    grouped_utilization
  end

  def on_time_seconds
    Date.today.to_time.to_i + self.on_time.hours
  end

  def off_time_seconds
    Date.today.to_time.to_i + self.off_time.hours
  end
  
  def hour_in_seconds(hour)
    Date.today.to_time.to_i + hour.hours
  end

  def elapsed_seconds_today
    now = Time.now.to_i
    off = off_time_seconds
    off = now if now < off
    
    off - on_time_seconds
  end
  
  def cycles_between(lower, upper)
    cycles.where('(started >= ? and started < ?) or ' +
                  '(stopped >= ? and stopped < ?) or ' +
                  '(started < ? and stopped > ?) or ' +
                  '(stopped is NULL)',
                   lower, upper, lower, upper, lower, upper)
  end
  
  def compute_daily_utilization
    elapsed = elapsed_seconds_today
    if elapsed <= 0
      0
    else
      s, e = on_time_seconds, off_time_seconds
      sum = (self.cycles_between(s, e).inject(0) do |total, cycle|
        total + cycle.bounded_duration(s, e)
      end)
      logger.info "Cycling for #{sum} seconds" 
      (sum * 100) / elapsed
    end
  end
  
  def update_daily_utilization
    hour = Time.now.hour
    logger.info "Updating daily utilization for #{id} at #{hour} (#{on_time}, #{off_time})"
    if hour >= on_time and hour <= off_time
      self.daily_utilization = compute_daily_utilization
    elsif hour < on_time
      self.daily_utilization = 0
      
      # Clear all dependent rows
      midnight = Date.today.to_time.to_i
      
      self.cycles.where('started < ?', midnight).delete_all
      self.hourly_utilizations.clear
      self.alarms.clear
      
      
    end
    self.save
  end
    
  def update_hourly_utilization
    # make sure the day as begun
    hour = Time.now.hour
    if hour >= on_time and hour <= off_time
      # Do a quick recovery check
      u = hourly_utilizations.order('hour desc').first
      if u.nil? or u.hour < hour - 1
        recover_hourly_utilization(hour - 1)
        u = HourlyUtilization.create(device_id: id, hour: hour)
      elsif u.hour == hour - 1
        # Close off the previous record and start a new one
        u.update_attributes(:utilization => compute_hourly_utilization(hour - 1))
        u = HourlyUtilization.create(device_id: id, hour: hour)
      end        
      
      u.update_attributes(:utilization => compute_hourly_utilization(hour))
    end
  end
  
  def compute_hourly_utilization(hour)
    # Find all cycles    
    now = Time.now.to_i
    s = hour_in_seconds(hour)
    e = s + 1.hour
    e = now if e > now
    
    # Bound the cycles to the hour and sum the durations
    sum = cycles_between(s, e).map { |c|
      c.bounded_duration(s, e)
    }.inject(0, :+)
    logger.info "#{id} - Total cycle time for hour #{hour} is #{sum}"
    
    (sum * 100) / (e - s)                             
  end
  
  def recover_hourly_utilization(hour)
    (on_time..hour).each do |h|
      u = hourly_utilizations.where('hour = ?', h).first || 
            HourlyUtilization.create(device_id: id, hour: h)
      u.update_attributes(:utilization => compute_hourly_utilization(h))
    end
  end
end
