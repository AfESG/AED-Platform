class SurveyAerialTotalCountStratum < ActiveRecord::Base
  include Stratum

  # All normal attributes of Stratum models are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :population_estimate

  belongs_to :survey_aerial_total_count
end
