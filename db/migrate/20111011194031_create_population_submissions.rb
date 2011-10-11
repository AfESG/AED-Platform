class CreatePopulationSubmissions < ActiveRecord::Migration
  def self.up
    create_table :population_submissions do |t|
      t.integer :submission_id
      t.string :data_licensing
      t.date :embargo_date
      t.string :site_name
      t.string :designate
      t.integer :area
      t.integer :completion_year
      t.integer :completion_month
      t.string :season
      t.string :survey_type
      t.string :survey_type_other

      t.timestamps
    end
  end

  def self.down
    drop_table :population_submissions
  end
end
