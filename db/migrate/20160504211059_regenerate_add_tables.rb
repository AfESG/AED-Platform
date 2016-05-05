class RegenerateAddTables < ActiveRecord::Migration

  def change
    run_file 'estimate_factors_analyses_categorized_for_add.4.2.sql'
    
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
