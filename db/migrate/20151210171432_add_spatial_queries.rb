class AddSpatialQueries < ActiveRecord::Migration
  def up
    run_file 'estimate_factors_analyses_categorized_for_add.3.sql'
    run_file 'static_spatial_queries_add.sql'
  end

  def down
    ['survey_range_intersection_metrics_add', 'survey_range_intersections_add', 'survey_geometry_locator_buffered_add'].each do |table|
      execute "DROP TABLE IF EXISTS #{table}"
    end
    ['survey_geometry_locator_add', 'estimate_locator_add'].each do |view|
      execute "DROP VIEW IF EXISTS #{view}"
    end
    run_file 'estimate_factors_analyses_categorized_for_add.sql'
    run_file 'estimate_factors_analyses_categorized_for_add.2.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end

end
