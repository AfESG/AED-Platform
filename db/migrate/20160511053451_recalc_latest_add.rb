require 'sql_helper'

class RecalcLatestAdd < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160511'
  end

  def down
    build_calculator '20160424'
  end

end
