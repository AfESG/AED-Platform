class SurveyGroundTotalCount < ActiveRecord::Base

  belongs_to :population_submission

  has_many :survey_ground_total_count_strata

end
