class PopulationAndInputZoneViews < ActiveRecord::Migration
  def up
    run_etl_script 'population_and_input_zone_views.sql'
  end

  def down
    execute 'DROP VIEW IF EXISTS populations;' +
            'DROP VIEW IF EXISTS input_zones;' +
            'DROP VIEW IF EXISTS input_zones_years;'
  end
end
