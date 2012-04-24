class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.integer :continent_id
      t.string :name
      t.timestamps
    end
    add_column :countries, :region_id, :integer
  end
end
