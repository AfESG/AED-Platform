class AddSourceAndBindingToPopulationSubmissionGeometries < ActiveRecord::Migration
  def change
    add_column :population_submission_geometries, :population_submission_attachment_id, :integer
    add_column :population_submission_geometries, :stratum, :integer
  end
end
