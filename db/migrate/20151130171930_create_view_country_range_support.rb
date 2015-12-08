class CreateViewCountryRangeSupport < ActiveRecord::Migration
  def up
    path = File.join Rails.root, 'script', 'etl', 'country_range_support.sql'
    SqlReader.parse(path) { |sql| execute sql }
  end
  def down
    execute 'DROP VIEW IF EXISTS country_range_by_category'
    execute 'DROP VIEW IF EXISTS country_range_totals'
  end
end
