class AddPopulationSubmissionLatLong < ActiveRecord::Migration
  def change
    add_column :population_submissions, :latitude, :float
    add_column :population_submissions, :longitude, :float
  end
end
