require 'sql_helper'

class UseUnionedRanges < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160818'
  end

  def down
    build_calculator '20160811'
  end

end
