require 'sql_helper'

class Run20220221Calc < ActiveRecord::Migration
  include SqlHelper

  def up
    build_calculator '20220221_forest_only'
  end

  def down
    build_calculator '20160821'
  end
end
