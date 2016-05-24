class UpdateCocCalculator < ActiveRecord::Migration

  def change
    run_file '2500_country_change_interpreters_add.sql'
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'calculator', '20160524', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
