class CreateSurveyModeledExtrapolations < ActiveRecord::Migration
  def self.up
    create_table :survey_modeled_extrapolations do |t|
      t.integer :population_submission_id
      t.string :other_method_description
      t.integer :population_estimate_min
      t.integer :population_estimate_max
      t.integer :mike_site_id
      t.boolean :is_mike_site
      t.integer :actually_seen
      t.boolean :informed
      t.integer :survey_geometry_id
      t.integer :stratum_area

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_modeled_extrapolations
  end
end
