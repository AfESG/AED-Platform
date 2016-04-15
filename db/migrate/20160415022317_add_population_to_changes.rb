class AddPopulationToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :population, :string
  end
end
