class DegradeChanges < ActiveRecord::Migration

  def change
    run_file '2510_create_add_change_interpreters_base_queries.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'calculator', '20160609', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
