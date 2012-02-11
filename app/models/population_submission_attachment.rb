class PopulationSubmissionAttachment < ActiveRecord::Base

  belongs_to :population_submission
  has_attached_file :file,
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET'],
      :access_key_id => ENV['S3_ACCESS_KEY_ID'],
      :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
    },
    :path => "/:id/:filename"

end
