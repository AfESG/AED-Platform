require 'sql_helper'

class Run0818Calc < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160821'
  end

  def down
    build_calculator '20160818'
  end

end
