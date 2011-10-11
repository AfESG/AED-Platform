class CreateDataRequestForms < ActiveRecord::Migration
  def self.up
    create_table :data_request_forms do |t|
      t.string :name
      t.string :title
      t.string :department
      t.string :organization
      t.string :telephone
      t.string :fax
      t.string :email
      t.string :website
      t.text :address
      t.string :town
      t.string :post_code
      t.string :state
      t.string :country
      t.text :extracts
      t.text :research
      t.text :subset_other
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :data_request_forms
  end
end

