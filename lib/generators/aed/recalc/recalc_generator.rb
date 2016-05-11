module Aed
  class RecalcGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number dir
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def create_recalc
      path = File.join(Rails.root, 'script', 'calculator')
      @previous = Dir.glob(File.join(path, '*')).max { |a,b| File.ctime(a) <=> File.ctime(b) }
      @current = Time.now.strftime("%Y%m%d")

      FileUtils.cp_r @previous, File.join(Rails.root, 'script', 'calculator', @current)

      @previous = File.basename(@previous)

      migration_template 'sql.erb', File.join(Rails.root, 'db', 'migrate', "#{file_name.underscore}.rb")
    end

  end
end
