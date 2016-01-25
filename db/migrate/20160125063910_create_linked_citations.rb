class CreateLinkedCitations < ActiveRecord::Migration
  def change
    create_table :linked_citations do |t|
      t.string :long_citation
      t.string :short_citation
      t.string :uri
      t.text :description
      t.integer :population_submission_id

      t.timestamps null: false
    end
  end
end
