class CreateSurveyIndividualRegistrations < ActiveRecord::Migration
  def self.up
    create_table :survey_individual_registrations do |t|
      t.integer :population_submission_id
      t.integer :population_estimate
      t.integer :population_upper_range
      t.integer :monitoring_years
      t.string :monitoring_frequency
      t.boolean :fenced_site

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_individual_registrations
  end
end
