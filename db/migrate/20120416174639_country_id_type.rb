class CountryIdType < ActiveRecord::Migration
  def change
    add_column :submissions, :tmp_species, :integer
    execute <<-SQL
      update submissions set tmp_species=cast(species_id as int);
    SQL
    remove_column :submissions, :species_id
    rename_column :submissions, :tmp_species, :species_id

    add_column :submissions, :tmp_country, :integer
    execute <<-SQL
      update submissions set tmp_country=cast(country_id as int);
    SQL
    remove_column :submissions, :country_id
    rename_column :submissions, :tmp_country, :country_id
  end
end
