class SurveyFaecalDna < ActiveRecord::Base
  include Count

  belongs_to :population_submission

  has_many :survey_faecal_dna_strata

  validates_with StratumLevelValidator
end
