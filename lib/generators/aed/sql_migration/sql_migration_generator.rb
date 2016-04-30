module Aed
  class SqlMigrationGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number dir
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def create_sql_migration
      files = []

      if args.empty?
        files << file_name
        @file_name = File.basename(file_name, ".*").gsub(/\./, '').camelize
      else
        files = args
        @file_name = file_name.camelize
      end

      files.collect! { |file| File.basename(file) }

      missing = []
      folder = File.join(Rails.root, 'script', 'etl')
      files.each do |file|
        missing << file unless File.exists?(File.join(folder, file))
      end

      if missing.any?
        say "The following files could not be located in #{folder}:", :red
        missing.each { |file| say " - #{file}", :red }
        say "Please correct these file names to continue.", :red
        return
      end

      @sql_files = files

      migration_template 'sql.erb', File.join(Rails.root, 'db', 'migrate', "#{file_name.underscore}.rb")
    end

    private

    def format_filename name
      File.basename(name, ".*").camelize
    end

  end
end
