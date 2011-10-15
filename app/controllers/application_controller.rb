class ApplicationController < ActionController::Base
  def authenticate_superuser!
    unless authenticate_user!
      return false
    end
    unless user_signed_in? && current_user.admin?
      flash[:alert] = "Access not allowed."
      redirect_to :controller => 'welcome', :action => 'index'
      warden.custom_failure! if performed?
      return false
    end
  end

  protect_from_forgery
end
