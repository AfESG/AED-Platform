# SQL helper methods for migrations
module SqlHelper

  def run_etl_script file
    path = File.join(Rails.root, 'script', 'etl', file)
    SqlReader.parse(path) { |sql| execute sql }
  end

  def preflush_calculator date
    puts "Pre-flushing calculator version #{date}"
    path = File.join(Rails.root, 'script', 'calculator', date, '1000_flush_analyses_view_dependencies.sql')
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
    refresh_materialized_views
  end

  def refresh_materialized_views(mat_views = nil)
    list_sql = 'SELECT matviewname FROM pg_matviews'
    mat_views ||= ActiveRecord::Base.connection.execute(list_sql).map { |x| x['matviewname'] }
    mat_views.each do |mat_view|
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{mat_view}")
    end
  end
end
