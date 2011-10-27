class SurveyIndividualRegistration < ActiveRecord::Base
  validates_presence_of :population_estimate
  validates_presence_of :monitoring_years
  validates_presence_of :monitoring_frequency
  validates_presence_of :fenced_site

  belongs_to :population_submission

end
