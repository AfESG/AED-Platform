require 'sql_helper'

class AddChangeInterpreters < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160516'
  end

  def down
    # build_calculator '20160511'
  end

end
