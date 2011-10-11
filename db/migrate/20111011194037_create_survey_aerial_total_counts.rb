class CreateSurveyAerialTotalCounts < ActiveRecord::Migration
  def self.up
    create_table :survey_aerial_total_counts do |t|
      t.integer :population_submission_id
      t.boolean :surveyed_at_stratum_level
      t.boolean :stratum_level_data_submitted

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_aerial_total_counts
  end
end
