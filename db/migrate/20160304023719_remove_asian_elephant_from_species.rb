class RemoveAsianElephantFromSpecies < ActiveRecord::Migration
  def change
    Species.find(2).destroy
  end
end
