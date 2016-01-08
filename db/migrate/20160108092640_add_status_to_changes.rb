class AddStatusToChanges < ActiveRecord::Migration
  def change
    add_column :changes, :status, :string
  end
end
