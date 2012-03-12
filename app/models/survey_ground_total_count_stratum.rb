class SurveyGroundTotalCountStratum < ActiveRecord::Base
  has_paper_trail

  include Stratum

  # All normal attributes of Stratum models are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :population_estimate

  belongs_to :survey_ground_total_count
end
