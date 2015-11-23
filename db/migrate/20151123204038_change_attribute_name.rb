class ChangeAttributeName < ActiveRecord::Migration
  def change
    rename_column :population_submission_geometries, :attributes, :geom_attributes
  end
end
