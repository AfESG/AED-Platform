class CreateSurveyDungCountLineTransectStrata < ActiveRecord::Migration
  def self.up
    create_table :survey_dung_count_line_transect_strata do |t|
      t.integer :survey_dung_count_line_transect_id
      t.string :stratum_name
      t.integer :stratum_area
      t.integer :population_estimate
      t.float :population_variance
      t.float :population_standard_error
      t.float :population_t
      t.integer :population_degrees_of_freedom
      t.float :population_confidence_limits
      t.boolean :population_no_precision_estimate_available
      t.integer :asymmetric_upper_confidence_limit
      t.integer :asymmetric_lower_confidence_limit
      t.integer :transects_covered
      t.integer :transects_covered_total_length
      t.float :strip_width
      t.integer :observations
      t.string :observations_distance_method
      t.integer :actually_seen
      t.integer :dung_piles
      t.string :dung_decay_rate_measurement_method
      t.integer :dung_decay_rate_estimate_used
      t.string :dung_decay_rate_measurement_site
      t.integer :dung_decay_rate_measurement_year
      t.string :dung_decay_rate_reference
      t.float :dung_decay_rate_variance
      t.float :dung_decay_rate_standard_error
      t.float :dung_decay_rate_t
      t.integer :dung_decay_rate_degrees_of_freedom
      t.float :dung_decay_rate_confidence_limits
      t.boolean :dung_decay_rate_no_precision_estimate_available
      t.boolean :defecation_rate_measured_on_site
      t.integer :defecation_rate_estimate_used
      t.string :defecation_rate_measurement_site
      t.string :defecation_rate_reference
      t.float :defecation_rate_variance
      t.float :defecation_rate_standard_error
      t.float :defecation_rate_t
      t.integer :defecation_rate_degrees_of_freedom
      t.float :defecation_rate_confidence_limits
      t.boolean :defecation_rate_no_precision_estimate_available
      t.integer :dung_density_estimate
      t.float :dung_density_variance
      t.float :dung_density_standard_error
      t.float :dung_density_t
      t.integer :dung_density_degrees_of_freedom
      t.float :dung_density_confidence_limits
      t.boolean :dung_density_no_precision_estimate_available
      t.integer :dung_encounter_rate

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_dung_count_line_transect_strata
  end
end
