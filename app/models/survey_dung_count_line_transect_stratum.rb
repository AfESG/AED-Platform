class SurveyDungCountLineTransectStratum < ActiveRecord::Base
  validates_presence_of :population_estimate
  validates_presence_of :dung_decay_rate_measurement_method
  validates_presence_of :dung_piles
  validates_presence_of :dung_decay_rate_estimate_used
  validates_presence_of :defecation_rate_measured_on_site
  validates_presence_of :defecation_rate_estimate_used
  validates_presence_of :dung_density_estimate

  belongs_to :survey_dung_count_line_transect

end
