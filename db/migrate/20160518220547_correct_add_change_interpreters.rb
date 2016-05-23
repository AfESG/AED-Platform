require 'sql_helper'

class CorrectAddChangeInterpreters < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160518'
  end

  def down
    build_calculator '20160516'
  end

end
