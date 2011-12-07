class SurveyGroundTotalCountStratum < ActiveRecord::Base
  include Stratum

  validates_presence_of :population_estimate

  belongs_to :survey_ground_total_count
end
