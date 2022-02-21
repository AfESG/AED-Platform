require 'sql_helper'

class Run20220221Calc < ActiveRecord::Migration
  include SqlHelper

  def up
    build_calculator '20220221'
  end

  def down
    build_calculator '20160821'
  end
end
