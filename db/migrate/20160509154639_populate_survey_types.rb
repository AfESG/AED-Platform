class PopulateSurveyTypes < ActiveRecord::Migration

  def change
    run_file 'generate_surveytypes.sql'
    
  end

  def run_file file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end


end
