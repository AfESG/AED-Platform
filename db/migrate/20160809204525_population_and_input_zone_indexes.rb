require 'sql_helper'

class PopulationAndInputZoneIndexes < ActiveRecord::Migration
  include SqlHelper

  def change
    run_etl_script 'population_and_input_zone_indexes.sql'
  end
end
