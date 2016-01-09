class TestRegeneratingAllStaticSpatialQueries < ActiveRecord::Migration
  def up
    execute 'END'
    run_file 'static_spatial_queries.sql'
    run_file 'static_spatial_queries_add.sql'
    execute 'BEGIN'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end
end
