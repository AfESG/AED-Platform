class SurveyAerialTotalCountStratum < ActiveRecord::Base
  include Stratum

  validates_presence_of :population_estimate

  belongs_to :survey_aerial_total_count
end
