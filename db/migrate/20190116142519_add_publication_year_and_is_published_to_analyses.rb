class AddPublicationYearAndIsPublishedToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :publication_year, :integer, null: true
    add_column :analyses, :is_published, :boolean, nul: false, default: false

    reversible do |dir|
      dir.up do
        Analysis.all.each do |a|
          a.update_attribute(:is_published, true)
        end

        Analysis.all.each do |a|
          if a.analysis_year == 2015
            a.publication_year = 2016
          else
            a.publication_year = a.analysis_year
          end
          a.save!
        end

        change_column :analyses, :publication_year, :integer, null: false
      end # up
    end # reversible

  end
end
