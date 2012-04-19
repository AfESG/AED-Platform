class AddMikeSiteId < ActiveRecord::Migration
  def change
    add_column :submissions, :mike_site_id, :integer
  end
end
