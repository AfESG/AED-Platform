require 'sql_helper'

class RebuildCalculatorWithPopulations < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160424'
  end

  def down
    # normally this would be the previous calculator version
    # but we don't have one, so down doesn't do anyything
  end

end
