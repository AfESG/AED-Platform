class CreateSurveyGroundSampleCountStrata < ActiveRecord::Migration
  def self.up
    create_table :survey_ground_sample_count_strata do |t|
      t.integer :survey_ground_sample_count_id
      t.string :stratum_name
      t.integer :stratum_area
      t.integer :population_estimate
      t.float :population_variance
      t.float :population_standard_error
      t.float :population_t
      t.integer :population_degrees_of_freedom
      t.float :population_confidence_limits
      t.boolean :population_no_precision_estimate_available
      t.integer :transects_covered
      t.integer :transects_covered_total_length
      t.integer :person_hours

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_ground_sample_count_strata
  end
end
