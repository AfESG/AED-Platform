class PopulationSubmissionsController < ApplicationController

  include SurveyCrud

  def index
    @population_submissions = PopulationSubmission.joins(:submission).order(translated_sort_column + ' ' + sort_direction);
    unless sort_column=='created_at'
      # always add a secondary sort, to enforce a guaranteed order
      @population_submissions = @population_submissions.order('created_at desc');
    end
    respond_to do |format|
      format.html
    end
  end

  def my
    @population_submissions = PopulationSubmission.joins(:submission).where("submissions.user_id = ?",current_user.id).order('created_at desc')
    respond_to do |format|
      format.html
    end
  end

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.submission = Submission.find(params[:submission_id])
  end

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_#{level_base_name}_#{@level.count_base_name}_path(@level)"
  end

  def submit
    edit
  end

  helper_method :sort_column, :sort_direction

  def sort_column
    params[:sort] || "id"
  end

  def translated_sort_column
    if sort_column=="country"
      "country_id"
    else
      sort_column
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end

end
