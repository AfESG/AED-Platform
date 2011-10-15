class SurveyGroundSampleCount < ActiveRecord::Base

  belongs_to :population_submission

  has_many :survey_ground_sample_count_strata

end
