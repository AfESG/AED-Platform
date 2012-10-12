class AddCountryToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :country, :string
  end
end
