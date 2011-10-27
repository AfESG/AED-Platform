class SurveyDungCountLineTransect < ActiveRecord::Base
  validates_presence_of :surveyed_at_stratum_level
  validates_presence_of :stratum_level_data_submitted

  belongs_to :population_submission

  has_many :survey_dung_count_line_transect_strata

end
