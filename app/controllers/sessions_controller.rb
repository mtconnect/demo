class SessionsController < ApplicationController
  layout 'devices'

  PASSWORD = File.read("#{RAILS_ROOT}/config/auth").strip

  def index
  end

  def create
    respond_to do |format|
      if params[:password] == PASSWORD
        logger.info "Logged in"
        session[:authorized] = true
        format.html {  redirect_to devices_url }
      else
        logger.error "Invalid password #{params[:passord]}"
        flash[:error] = 'Incorrect password'
        format.html {  redirect_to sessions_url }
      end
    end
  end
end
