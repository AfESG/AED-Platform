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
    redirect_to(AWS::S3::S3Object.url_for(path, attachment.file.bucket_name, :expires_in => 10.seconds))
  end
end
