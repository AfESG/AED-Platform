class RestructureMikeSites < ActiveRecord::Migration
  def change
    drop_table :mike_sites
    create_table :mike_sites do |t|
      t.integer :country_id
      t.string :subregion
      t.string :site_code
      t.text :site_name
      t.integer :area
      t.timestamps
    end
  end
end
