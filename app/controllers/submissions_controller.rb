class SubmissionsController < ApplicationController

  include SurveyCrud

  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authenticate_superuser!, :only => [:index, :show]

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_submission_population_submission_path(@level)"
  end

end
