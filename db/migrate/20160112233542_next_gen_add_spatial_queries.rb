class NextGenAddSpatialQueries < ActiveRecord::Migration
  def up
    run_file 'estimate_factors_analyses_categorized_for_add.3.sql'
    run_file 'static_spatial_queries_add.2.sql'
    run_file 'country_range_support.sql'
  end

  def down
    run_file 'estimate_factors_analyses_categorized_for_add.3.sql'
    run_file 'static_spatial_queries_add.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end

end
