class SessionsController < ApplicationController
  @@password = File.read("#{Rails.root}/config/auth.txt").strip

  def new 
  end

  def create
    if params[:session][:password] == @@password
      session[:authorized] = true
      redirect_to devices_path
    else
      flash[:error] = 'Incorrect password'
      redirect_to login_path
    end
  end

  def destroy
    session[:authorized] = false
    redirect_to devices_path
  end
end
