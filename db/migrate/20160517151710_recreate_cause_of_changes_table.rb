class RecreateCauseOfChangesTable < ActiveRecord::Migration

  def change
    run_file 'update_causes_of_change_table.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
