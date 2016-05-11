# SQL helper methods for migrations
module SqlHelper

  def run_etl_script file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end

  def build_calculator date
    puts "Building calculator version #{date}"
    path = File.join(Rails.root, 'script', 'calculator', date)
    Dir.entries(path).sort.each do |file|
      if file.end_with?('sql')
        puts "Executing #{file}"
        script = File.join(path, file)
        SqlReader.parse(script) { |sql| execute sql }
      end
    end
  end

end
