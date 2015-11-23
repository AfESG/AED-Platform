class PopulationSubmissionAttachmentsController < ApplicationController
  include SurveyCrud
  
  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.population_submission = PopulationSubmission.find(params[:population_submission_id])
  end

  def download
    head(:not_found) and return if (attachment = PopulationSubmissionAttachment.find_by_id(params[:id])).nil?
    path = attachment.file.path
    uri = attachment.file.s3_object.url_for(:read, :secure => false, :expires_in => 10.seconds, :response_content_disposition => 'attachment' )
    redirect_to uri.to_s
  end
end
