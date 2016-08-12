require 'sql_helper'

class Run0811Calc < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160811'
  end

  def down
    build_calculator '20160722'
  end

end
