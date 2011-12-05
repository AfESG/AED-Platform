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
      puts "Setting @submission on #{self} to #{@submission}"
    elsif object.respond_to? :population_submission
      @population_submission = object.population_submission
      puts "Setting @population_submission on #{self} to #{@population_submission}"
      @submission = @population_submission.submission
      puts "Setting @submission on #{self} to #{@submission}"
    elsif object.class.name =~ /Stratum/
      n = object.class.name.gsub('Stratum','').underscore
      e =  "object.#{n}.population_submission"
      puts "Going to eval #{e}"
      @population_submission = eval e
      puts "Setting @population_submission on #{self} to #{@population_submission}"
      @submission = @population_submission.submission
      puts "Setting @submission on #{self} to #{@submission}"
    end
  end

  protect_from_forgery
end
