class PopulationSubmissionAttachment < ActiveRecord::Base
  has_paper_trail

  attr_accessible(
    :population_submission_id,
    :file,
    :attachment_type,
    :restrict
  )

  belongs_to :population_submission
  has_attached_file :file,
    :storage => :s3,
    :s3_permissions => 'private',
    :s3_protocol => 'http',
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET'],
      :access_key_id => ENV['S3_ACCESS_KEY_ID'],
      :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
    },
    :s3_headers => { :content_disposition => 'attachment' },
    :path => "/:id/:filename"

  def can_access_file(user)
    unless user.nil?
      return true if user.admin?
    end
    if restrict?
      return false
    end
    return true
  end
end
