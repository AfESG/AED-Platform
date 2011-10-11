class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.integer :user_id
      t.string :species
      t.string :country
      t.string :phenotype
      t.string :phenotype_basis
      t.string :data_type
      t.boolean :right_to_grant_permission
      t.string :permission_email
      t.boolean :mike_site

      t.timestamps
    end
  end

  def self.down
    drop_table :submissions
  end
end
