class ApplicationController < ActionController::Base

  before_filter :authenticate
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def allowed_preview?
    p params
    if params[:filter] == '2013_africa_final' and params[:year] == '2013'
      return true
    end
    if current_user
      current_user.admin?
    else
      false
    end
  end

  def maybe_authenticate_user!
    if allowed_preview?
      return true
    end
    authenticate_user!
  end

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

  protected

  def authenticate
    if !ENV['authenticate_all_requests'].nil?
      authenticate_or_request_with_http_basic do |username, password|
        username == "pachyderm" && password == ENV['authenticate_all_requests']
      end
    else
      true
    end
  end

  def sql_escape(str)
    conn = ActiveRecord::Base.connection.instance_variable_get("@connection")
    conn.escape(str)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit! }
  end

end
