class SurveyFaecalDna < ActiveRecord::Base

  belongs_to :population_submission

  has_many :survey_faecal_dna_strata

end
