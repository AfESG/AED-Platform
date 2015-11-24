class AddSurveyGeom < ActiveRecord::Migration
  def change
    add_column :survey_geometries, :geom, :geometry
  end
end
