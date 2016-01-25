class AddCommentsToPopulationSubmission < ActiveRecord::Migration
  def change
    add_column :population_submissions, :comments, :text
  end
end
