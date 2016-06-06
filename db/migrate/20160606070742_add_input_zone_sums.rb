class AddInputZoneSums < ActiveRecord::Migration

  def change
    run_file '1110_estimate_factors_analyses_categorized_for_add.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'calculator', '20160606', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
