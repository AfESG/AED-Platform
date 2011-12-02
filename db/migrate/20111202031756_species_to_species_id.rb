class SpeciesToSpeciesId < ActiveRecord::Migration
  def up
    rename_column :submissions, :species, :species_id
  end

  def down
    rename_column :submissions, :species_id, :species
  end
end
