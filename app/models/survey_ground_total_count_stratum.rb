class SurveyGroundTotalCountStratum < ActiveRecord::Base
  validates_presence_of :population_estimate

  belongs_to :survey_ground_total_count

end
