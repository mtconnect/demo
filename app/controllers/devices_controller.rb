class DevicesController < ApplicationController
  before_filter :authorize!, :only => [:new, :create, :edit, :update, :destroy]

  def index
    if session[:authorized]    
      @devices = Device.all.order('name') 
      @apps = App.all.order('name') 
    else
      @devices = Device.active.order('name') 
      @apps = App.active.order('name')
      @cache_key = [@devices.max_by(&:updated_at), @apps.max_by(&:updated_at)].
          max_by(&:updated_at).try(:updated_at).to_i.to_s
    end
  end

  def show
    @device = Device.find(params[:id])
    respond_to do |format|
      format.html do
        @data = @device.get_data
      end
      format.json { render :json => @device.to_json(:methods => [:elapsed_hourly_utilization, :elapsed_daily_utilization]) }
    end
  end

  def new
    @device = Device.new(:enabled => true, :on_time => 9, :off_time => 19)
  end

  def create
    @device = Device.new(params[:device])
    if @device.save
      flash[:notice] = "Device created successfully."
      redirect_to devices_path
    else
      flash.now[:error] = "There were problems in creating a device"
      render :new
    end
  end

  def edit
    @device = Device.find(params[:id])
  end

  def update 
    @device = Device.find(params[:id])
    qrf = params[:device].delete('quality_report_file')
    params[:device][:quality_report] = 'SPC_1' if qrf
    if @device.update_attributes(params[:device])
      flash[:notice] = "Device updated successfully"

      if qrf
        doc = REXML::Document.new(qrf.read)
        @device.generate_quality_report('SPC_1', doc)
      end

      redirect_to devices_path
    else
      flash.now[:error] = "Device was not updated"
      render :new
    end
  end

  def destroy
    @device = Device.find(params[:id])
    if @device.destroy
      flash[:notice] = "Device deleted successfully"
      redirect_to devices_path
    else
      flash[:notice] = "Device was not deleted"
      redirect_to devices_path
    end
  end

  def update_hmi
    @device = Device.find(params[:id])
    @data = @device.get_data
    render :template => "devices/_hmi", :layout => false
  end

  def update_alarms
    @device = Device.find(params[:id])
    render :template => "devices/_alarms", :layout => false
  end

  def update_activity
    @device = Device.find(params[:id])
    render :template => "devices/_activity", :layout => false
  end
end
