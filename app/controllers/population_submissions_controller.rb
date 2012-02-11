class PopulationSubmissionsController < ApplicationController

  include SurveyCrud

  def index
    @population_submissions = PopulationSubmission.all :order => 'created_at desc'
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

end
