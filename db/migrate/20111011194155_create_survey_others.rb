class CreateSurveyOthers < ActiveRecord::Migration
  def self.up
    create_table :survey_others do |t|
      t.integer :population_submission_id
      t.string :other_method_description
      t.integer :population_estimate_min
      t.integer :population_estimate_max

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_others
  end
end
