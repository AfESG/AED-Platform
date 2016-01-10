class AddRailsBitsToAnalysis < ActiveRecord::Migration
  def up
    run_file 'flush_analyses_view_dependencies.sql'
    add_column :analyses, :created_at, :timestamp
    add_column :analyses, :updated_at, :timestamp
    rename_column :analyses, :analysis_id, :id
    change_column :analyses, :analysis_name, :string
    # Some things were converted to tables undocumentedly
    begin
      execute 'drop table if exists i_dpps_sums_country_category_reason cascade;'
    rescue Exception => e
      puts e.inspect
    end
    run_file 'new_estimates_views.sql'
    run_file 'new_change_interpreters.sql'
    run_file 'country_change_interpreters.sql'
    run_file 'regional_change_interpreters.sql'
    run_file 'continental_change_interpreters.sql'
    run_file 'estimate_factors_analyses_categorized_for_add.3.sql'
    run_file 'country_range_support.sql'
  end

  def down
    run_file 'flush_analyses_view_dependencies.sql'
    change_column :analyses, :analysis_name, :text
    rename_column :analyses, :id, :analysis_id
    remove_column :analyses, :created_at
    remove_column :analyses, :updated_at
    run_file 'new_estimates_views.sql'
    run_file 'new_change_interpreters.sql'
    run_file 'country_change_interpreters.sql'
    run_file 'regional_change_interpreters.sql'
    run_file 'continental_change_interpreters.sql'
    run_file 'estimate_factors_analyses_categorized_for_add.3.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end
end
