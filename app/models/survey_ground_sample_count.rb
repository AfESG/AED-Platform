class SurveyGroundSampleCount < ActiveRecord::Base
  include Count

  belongs_to :population_submission

  has_many :survey_ground_sample_count_strata

  validates_with StratumLevelValidator
end
