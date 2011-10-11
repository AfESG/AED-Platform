class CreateSurveyAerialSampleCounts < ActiveRecord::Migration
  def self.up
    create_table :survey_aerial_sample_counts do |t|
      t.integer :population_submission_id
      t.integer :total_possible_transects
      t.boolean :surveyed_at_stratum_level
      t.boolean :stratum_level_data_submitted

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_aerial_sample_counts
  end
end
