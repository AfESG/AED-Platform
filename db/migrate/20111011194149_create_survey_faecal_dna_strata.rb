class CreateSurveyFaecalDnaStrata < ActiveRecord::Migration
  def self.up
    create_table :survey_faecal_dna_strata do |t|
      t.integer :survey_faecal_dna_id
      t.string :stratum_name
      t.integer :stratum_area
      t.integer :population_estimate
      t.float :population_variance
      t.float :population_standard_error
      t.float :population_t
      t.integer :population_degrees_of_freedom
      t.float :population_confidence_limits
      t.boolean :population_no_precision_estimate_available
      t.string :method_of_analysis
      t.string :area_calculation_method
      t.integer :genotypes_identified
      t.integer :samples_analyzed
      t.integer :sampling_locations

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_faecal_dna_strata
  end
end
