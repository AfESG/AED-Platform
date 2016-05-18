require 'sql_helper'

class RecreateIzExporter < ActiveRecord::Migration

  include SqlHelper

  def up
    run_etl_script 'input_zone_exporter_view.sql'
  end

  def down
  end

end
