class SurveyFaecalDna < ActiveRecord::Base
  has_paper_trail

  include Count

  # All normal attributes of Count models are mass-assignable
  attr_protected :created_at, :updated_at

  belongs_to :population_submission

  has_many :survey_faecal_dna_strata

  validates_with StratumLevelValidator
end
