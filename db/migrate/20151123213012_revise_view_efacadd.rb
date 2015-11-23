class ReviseViewEfacadd < ActiveRecord::Migration
  def up
    run_file 'estimate_factors_analyses_categorized_for_add.2.sql'
  end
  def down
    # Go back to the first version; script has a drop command.
    run_file 'estimate_factors_analyses_categorized_for_add.sql'
  end
  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end
end
