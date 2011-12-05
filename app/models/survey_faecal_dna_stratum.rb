class SurveyFaecalDnaStratum < ActiveRecord::Base
  include Stratum

  validates_presence_of :population_estimate
  validates_presence_of :method_of_analysis

  belongs_to :survey_faecal_dna
end
