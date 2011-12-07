class SurveyDungCountLineTransect < ActiveRecord::Base
  include Count

  belongs_to :population_submission

  has_many :survey_dung_count_line_transect_strata

  validates_with StratumLevelValidator
end
