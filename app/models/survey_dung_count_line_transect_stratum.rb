class SurveyDungCountLineTransectStratum < ActiveRecord::Base
  validates_presence_of :population_estimate
  validates_presence_of :dung_decay_rate_measurement_method
  validates_presence_of :dung_decay_rate_estimate_used
  validates_presence_of :defecation_rate_measured_on_site
  validates_presence_of :defecation_rate_estimate_used
  validates_presence_of :dung_density_estimate

  belongs_to :survey_dung_count_line_transect
  
  class SurveyDungCountLineTransectStratumValidator < ActiveModel::Validator
    def validate(record)
      p record
      if record.dung_decay_rate_reference == "" and record.dung_decay_rate_measurement_method == "Decay rate NOT measured on site"
        record.errors[:dung_decay_rate_reference] << "must be provided if decay rate was not measured on site"
      end
      if record.dung_piles.nil? and !record.dung_decay_rate_measurement_method == "Decay rate NOT measured on site"
        record.errors[:base] << "If decay rate was measured on site, you must provide blah blah"
      end
    end
  end
  
  validates_with SurveyDungCountLineTransectStratumValidator
end
