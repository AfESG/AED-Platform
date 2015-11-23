class GenerateViewEfacadd < ActiveRecord::Migration
  def up
    path = File.join(Rails.root, 'script', 'etl', 'estimate_factors_analyses_categorized_for_add.sql')
    SqlReader.parse(path) { |sql| execute sql }
  end
  def down
    execute "DROP VIEW IF EXISTS estimate_factors_analyses_categorized_for_add"
  end
end
