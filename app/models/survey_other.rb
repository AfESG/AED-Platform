class SurveyOther < ActiveRecord::Base
  validates_presence_of :other_method_description
  validates_presence_of :population_estimate_min
  validates_presence_of :population_estimate_max

  belongs_to :population_submission

end
