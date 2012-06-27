class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.string :analysis_name
      t.integer :analysis_year
      t.string :replacement_name
      t.string :replaced_strata
      t.string :new_strata
      t.string :reason_change

      t.timestamps
    end
  end
end
