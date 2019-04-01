class AddAuthorsAndTitleToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :title, :string, null: true
    add_column :analyses, :authors, :string, null: true

    reversible do |dir|
      dir.up do
        # Make sure the column data from previous migrations is loaded.
        Analysis.connection.schema_cache.clear!
        Analysis.reset_column_information

        Analysis.all.each do |a|
          if a.publication_year == 2013
            a.title = 'Provisional African Elephant Population Estimates: update to 31 Dec 2013'
          else
            a.title = "#{a.publication_year} African Elephant Status Report"
          end

          a.authors = 'IUCN African Elephant Specialist Group'
          a.save!
        end

        change_column :analyses, :title, :string, null: false
        change_column :analyses, :authors, :string, null: false
      end # up
    end # reversible

  end
end
