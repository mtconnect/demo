class DevicesController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :update_hmi]

  caches_action :index, :unless => Proc.new { |c| c.session[:authorized] }
  cache_sweeper :device_sweeper, :only => [:create, :update, :destroy]
  
  # GET /devices
  # GET /devices.xml
  def index
    devices = Device.all(:include => :button)
    
    @applications, @devices = devices.partition { |d| d.application }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @devices }
    end
  end

  # GET /devices/1
  # GET /devices/1.xml
  def show
    @device = Device.find(params[:id], :include => [:button, :picture])
    unless @device.application
      get_device_data(@device)
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @device }
    end
  end

  def update_hmi
    @device = Device.find(params[:id])
    get_device_data(@device)

    respond_to do |format|
      format.html
      format.js do
        render :json => { :content => render_to_string(:partial => 'hmi', :layout => false) }
      end
    end
  end

  # GET /devices/new
  # GET /devices/new.xml
  def new
    @device = Device.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device }
    end
  end

  # GET /devices/1/edit
  def edit
    @device = Device.find(params[:id])
  end

  # POST /devices
  # POST /devices.xml
  def create
    @device = Device.new(params[:device])

    respond_to do |format|
      if @device.save
        flash[:notice] = 'Device was successfully created.'
        format.html { redirect_to(@device) }
        format.xml  { render :xml => @device, :status => :created, :location => @device }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /devices/1
  # PUT /devices/1.xml
  def update
    @device = Device.find(params[:id])

    respond_to do |format|
      if @device.update_attributes(params[:device])
        flash[:notice] = 'Device was successfully updated.'
        format.html { redirect_to(@device) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.xml
  def destroy
    @device = Device.find(params[:id])
    @device.destroy

    respond_to do |format|
      format.html { redirect_to(devices_url) }
      format.xml  { head :ok }
    end
  end

private
  def get_device_data(device)
    @data = device.get_data

    @power = @data.select do |comp|
      comp.component == "Power" and comp.item == 'PowerStatus'
    end

    # Controller data
    @control = @data.select do |comp|
      comp.component == "Controller" and
        ['Program', 'Block', 'ControllerMode', 'Execution'].include?(comp.item)
    end

    @spindle = @data.select do |comp|
      comp.component == 'Spindle' and comp.item == 'SpindleSpeed' and
        comp.sub_type == 'ACTUAL'
    end

    @alarm = @data.select do |comp|
      comp.item == 'Alarm'
    end

    @linear = @data.select do |comp|
      comp.component == 'Linear' and comp.item == 'Position' and
        comp.sub_type == 'ACTUAL'
    end.sort_by { |e| e.component_name }

    @rotary = @data.select do |comp|
      comp.component == 'Rotary' and comp.item == 'Angle' and
        comp.sub_type == 'ACTUAL'
    end.sort_by { |e| e.component_name }
  end

  def authorize
    unless session[:authorized]
      redirect_to devices_url
    end
  end
  
end
