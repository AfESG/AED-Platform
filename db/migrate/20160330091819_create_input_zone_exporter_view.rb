class CreateInputZoneExporterView < ActiveRecord::Migration
  def up
    path = File.join Rails.root, 'script', 'etl', 'input_zone_exporter_view.sql'
    SqlReader.parse(path) { |sql| execute sql }
  end
end
