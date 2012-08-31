class SurveyAerialSampleCountStratum < ActiveRecord::Base
  has_paper_trail

  include Stratum

  # All normal attributes of Stratum models are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :population_estimate

  belongs_to :survey_aerial_sample_count
  belongs_to :mike_site
  belongs_to :survey_geometry

  class SurveyAerialSampleCountStratumValidator < ActiveModel::Validator
    def validate(record)
      unless record.population_no_precision_estimate_available
        some_precision = false
        [:population_variance,
         :population_standard_error,
         :population_t,
         :population_degrees_of_freedom,
         :population_confidence_interval,
         :population_upper_confidence_limit,
         :population_lower_confidence_limit].each do |field|
          value = record.send field
          unless value.nil?
            some_precision = true
            break
          end
        end
        unless some_precision
          record.errors[:population_no_precision_estimate_available] << "must be checked if no other precision information is available"
        end
      end
    end
  end

  validates_with SurveyAerialSampleCountStratumValidator
end
