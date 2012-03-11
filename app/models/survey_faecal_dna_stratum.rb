class SurveyFaecalDnaStratum < ActiveRecord::Base
  include Stratum

  # All normal attributes of Stratum models are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :population_estimate
  validates_presence_of :method_of_analysis

  belongs_to :survey_faecal_dna
end
