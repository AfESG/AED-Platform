class SubmissionsController < ApplicationController

  include SurveyCrud

  before_filter :authenticate_user!, :except => [:index, :show]

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_submission_population_submission_path(@level)"
  end

  def index
    @submissions = Submission.order("created_at desc")
  end

end
