class PopulationSubmissionAttachment < ActiveRecord::Base
  has_paper_trail

  attr_accessible(
    :population_submission_id,
    :file,
    :attachment_type,
    :restrict
  )

  belongs_to :population_submission
  has_attached_file :file
  
  # WARNING: this defeats security checks to prevent
  # content type spoofing. But we do want users to be able
  # to upload different content types that the software does
  # not know how to parse
  do_not_validate_attachment_file_type :file

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
