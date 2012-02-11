class PopulationSubmissionAttachmentsController < ApplicationController
  include SurveyCrud

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.population_submission = PopulationSubmission.find(params[:population_submission_id])
  end

end
