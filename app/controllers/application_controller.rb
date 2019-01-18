class ApplicationController < ActionController::Base

  before_filter :authenticate
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :latest_report

  #
  # Gets the latest published Report (Analysis)
  #
  def latest_report
    @latest_report ||= AedUtils.latest_published_analysis
  end

  #
  # Gets if the request is for a legacy year or not.
  #
  def legacy_request?
    AedLegacy.legacy_year?(params[:year])
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
    return true if is_api_request?
    if !ENV['authenticate_all_requests'].nil?
      authenticate_or_request_with_http_basic do |username, password|
        username == "pachyderm" && password == ENV['authenticate_all_requests']
      end
    else
      true
    end
  end

  def is_api_request?
    request.fullpath[0..4].downcase == '/api/'
  end

  def sql_escape(str)
    conn = ActiveRecord::Base.connection.instance_variable_get("@connection")
    conn.escape(str)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit! }
  end

end
