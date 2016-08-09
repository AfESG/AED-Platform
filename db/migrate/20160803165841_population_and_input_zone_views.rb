require 'sql_helper'

class PopulationAndInputZoneViews < ActiveRecord::Migration

  include SqlHelper

  def change
    run_etl_script 'population_and_input_zone_views.sql'
  end
end
