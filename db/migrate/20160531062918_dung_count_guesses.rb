require 'sql_helper'

class DungCountGuesses < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160531'
  end

  def down
    build_calculator '20160518'
  end

end
