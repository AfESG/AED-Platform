class SurveyAerialSampleCountStratum < ActiveRecord::Base
  validates_presence_of :population_estimate

  belongs_to :survey_aerial_sample_count

end
