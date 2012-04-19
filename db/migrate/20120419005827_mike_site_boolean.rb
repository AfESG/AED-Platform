class MikeSiteBoolean < ActiveRecord::Migration
  def change
    rename_column :submissions, :mike_site, :is_mike_site
  end
end
