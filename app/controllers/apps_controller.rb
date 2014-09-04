class AppsController < ApplicationController
  before_filter :authorize!, :except => [:index, :show]
  
  def index
    @app = App.active(:order => 'name')
  end

  def new
    @app = App.new(:enabled => true)
  end

  def create
    @app = App.new(params[:app])
    if @app.save
      flash[:notice] = "Application has been saved successfully"
      expire_fragment('all_devices_and_apps')
      redirect_to root_path
    else
      flash.now[:error] = "Application cannot be saved."
      render :new
    end
  end

  def show
    @app = App.find(params[:id])
  end

  def edit
    @app = App.find(params[:id])
  end

  def update
    @app = App.find(params[:id])
    @app.attributes = params[:app]
    if @app.save
      flash[:notice] = "Application has been updated successfully"
      expire_fragment('all_devices_and_apps')
      redirect_to root_path
    else
      flash.now[:error] = "Application cannot be updated."
      render :edit
    end

  end

  def destroy
    @app = App.find(params[:id])
    if @app.destroy
      flash[:notice] = "Application has been deleted successfully"
      expire_fragment('all_devices_and_apps')
      redirect_to root_path
    else
      flash[:error] = "Application cannot be deleted."
      redirect_to apps_path
    end
  end
end
