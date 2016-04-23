class CreateRangePreviews < ActiveRecord::Migration
  def change
    create_table :range_previews do |t|
      t.string :range_type
      t.string :original_comments
      t.string :source_year
      t.string :published_year
      t.string :comments
      t.string :status
      t.geometry :geom

      t.timestamps null: false
    end
  end
end
