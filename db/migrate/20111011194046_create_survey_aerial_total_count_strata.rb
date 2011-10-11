class CreateSurveyAerialTotalCountStrata < ActiveRecord::Migration
  def self.up
    create_table :survey_aerial_total_count_strata do |t|
      t.integer :survey_aerial_total_count_id
      t.string :stratum_name
      t.integer :stratum_area
      t.integer :population_estimate
      t.float :population_variance
      t.float :population_standard_error
      t.float :population_t
      t.integer :population_degrees_of_freedom
      t.float :population_confidence_limits
      t.boolean :population_no_precision_estimate_available
      t.integer :average_speed
      t.integer :average_transect_spacing
      t.integer :average_searching_rate
      t.integer :transects_covered
      t.integer :transects_covered_total_length
      t.integer :observations
      t.integer :carcasses_fresh
      t.integer :carcasses_old
      t.integer :carcasses_very_old

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_aerial_total_count_strata
  end
end
