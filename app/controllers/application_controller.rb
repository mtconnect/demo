class ApplicationController < ActionController::Base
  protect_from_forgery

  def authorized?
    session[:authorized]
  end

  def authorize!
    redirect_to devices_path unless authorized?
  end
end
