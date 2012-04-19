class SubmissionsController < ApplicationController

  include SurveyCrud

  before_filter :authenticate_user!, :except => [:index, :show]

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_submission_population_submission_path(@level)"
  end

  def index
    @submissions = Submission.joins(:user).joins(:population_submissions).joins('join countries on submissions.country_id=countries.id').order(translated_sort_column + ' ' + sort_direction);
    unless sort_column=='created_at'
      # always add a secondary sort, to enforce a guaranteed order
      @submissions = @submissions.order('created_at desc');
    end
    respond_to do |format|
      format.html
    end
  end


  helper_method :sort_column, :sort_direction

  def sort_column
    params[:sort] || "id"
  end

  def translated_sort_column
    if sort_column=="country"
      "countries.name"
    elsif sort_column=="user"
      "users.name"
    else
      sort_column
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end

end