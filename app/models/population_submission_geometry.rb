class PopulationSubmissionGeometry < ActiveRecord::Base

  belongs_to :population_submission
  belongs_to :population_submission_attachment

end
