class AddShortCitation < ActiveRecord::Migration
  def change
    add_column :population_submissions, :short_citation, :string
  end
end
