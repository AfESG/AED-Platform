class SurveyGroundTotalCount < ActiveRecord::Base
  include Count

  belongs_to :population_submission

  has_many :survey_ground_total_count_strata
end
