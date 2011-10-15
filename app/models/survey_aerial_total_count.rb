class SurveyAerialTotalCount < ActiveRecord::Base

  belongs_to :population_submission

  has_many :survey_aerial_total_count_strata

end
