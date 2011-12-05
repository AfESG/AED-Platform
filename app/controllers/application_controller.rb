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

  def find_parents object
    if object.respond_to? :submission
      @submission = object.submission
    elsif object.respond_to? :population_submission
      @population_submission = object.population_submission
      @submission = @population_submission.submission
    elsif object.respond_to? :parent_count
      @population_submission = object.parent_count.population_submission
      @submission = @population_submission.submission
    end
  end

  protect_from_forgery
end
