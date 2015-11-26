class CreateViewAddTotals < ActiveRecord::Migration
  def up
    path = File.join Rails.root, 'script', 'etl', 'estimate_factors_analyses_categorized_totals_for_add.sql'
    SqlReader.parse(path) { |sql| execute sql }
  end
  def down
    execute 'DROP VIEW IF EXISTS estimate_factors_analyses_categorized_totals_for_add CASCADE'
    execute 'DROP VIEW IF EXISTS estimate_factors_analyses_categorized_sums_for_add CASCADE'
  end
end
