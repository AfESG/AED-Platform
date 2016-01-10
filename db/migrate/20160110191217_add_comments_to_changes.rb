class AddCommentsToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :comments, :text
  end
end
