class SurveyOther < ActiveRecord::Base
  has_paper_trail

  include Count

  # All normal attributes of Count models are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :other_method_description
  validates_presence_of :population_estimate_min
  validates_presence_of :population_estimate_max

  def stratum_level_data_submitted
    false
  end

  def surveyed_at_stratum_level
    false
  end

  def has_strata?
    false
  end

  belongs_to :population_submission
  belongs_to :mike_site
end
