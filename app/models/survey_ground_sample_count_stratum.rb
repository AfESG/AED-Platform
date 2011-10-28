class SurveyGroundSampleCountStratum < ActiveRecord::Base
  validates_presence_of :population_estimate

  belongs_to :survey_ground_sample_count

end
