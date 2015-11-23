class CreatePopulationSubmissionGeometries < ActiveRecord::Migration
  def change
    create_table :population_submission_geometries do |t|
      t.integer  :population_submission_id
      t.geometry :geom
      t.text :attributes
    end
  end
end
