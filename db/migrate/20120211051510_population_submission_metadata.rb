class PopulationSubmissionMetadata < ActiveRecord::Migration
  def change
    add_column :population_submissions, :abstract, :text
    add_column :population_submissions, :link, :text
    add_column :population_submissions, :citation, :text
    add_column :population_submissions, :submitted, :boolean
    add_column :population_submissions, :released, :boolean
  end
end
