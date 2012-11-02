class AppPicturesController < ApplicationController

  def index
    @app = App.find(params[:app_id])
    @app_pictures = @app.app_pictures
  end

  def destroy
    @app_picture = AppPicture.find(params[:id])
    if @app_picture.destroy
      flash[:notice] = "App picture deleted successfully"
      redirect_to app_app_pictures_path(@app_picture.app)
    else
      flash[:notice] = "App picture was not deleted"
      redirect_to app_app_pictures_path(@app_picture.app)
    end
  end
end
