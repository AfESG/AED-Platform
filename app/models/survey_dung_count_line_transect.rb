class SurveyDungCountLineTransect < ActiveRecord::Base

  belongs_to :population_submission

  has_many :survey_dung_count_line_transect_strata

end
