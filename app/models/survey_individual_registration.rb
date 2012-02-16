class SurveyIndividualRegistration < ActiveRecord::Base
  include Count

  validates_presence_of :population_estimate
  validates_presence_of :monitoring_years
  validates_presence_of :monitoring_frequency
  validates_presence_of :fenced_site
  validates_presence_of :porous_fenced_site

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
end
