# ETL script:
# Copy each of the historic standalone aed* tabular data sets into an
# appropriately named schema

require 'rubygems'
require 'sequel'
require 'find'
require 'rainbow'

TARGETID = "aaed_development"
TARGETDB = Sequel.connect("postgres://localhost/#{TARGETID}")

['aed1995','aed1998','aed2002','aed2007'].each do |source|
  SOURCEDB = Sequel.connect("postgres://localhost/#{source}")
  begin
    SOURCEDB << "CREATE SCHEMA #{source}"
  rescue
    puts "source schema already exists in #{source}".color(:yellow)
  end

  SOURCEDB.tables.each do |table|
    puts "Copy #{table} in #{source} to #{source} schema".color(:green)
    SOURCEDB << "CREATE TABLE #{source}.\"#{table}\" AS SELECT * FROM \"#{table}\""
    puts "Dump #{source}.#{table} in #{source}".color(:green)
    system "pg_dump -t \"#{source}.#{table}\" -f table.temp #{SISDBID}"

    puts "Restore #{source}.#{table} to #{TARGETID}".color(:green)
    system "psql -f table.temp #{TARGETID}"

    puts "Drop copy of #{table} in #{source}.#{source} schema".color(:green)
    SOURCEDB << "DROP TABLE #{source}.#{table}"
  end

  begin
    SOURCEDB << "DROP SCHEMA #{source}"
  rescue
    puts "source schema not dropped in in #{source}".color(:yellow)
  end

end

