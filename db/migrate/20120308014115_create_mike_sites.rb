class CreateMikeSites < ActiveRecord::Migration
  def change
    create_table :mike_sites do |t|
      t.integer :country_id
      t.integer :subregion
      t.integer :site_code
      t.integer :site_name
      t.integer :area
      t.timestamps
    end
  end
end
