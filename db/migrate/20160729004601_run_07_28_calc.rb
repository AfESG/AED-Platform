require 'sql_helper'

class 20160728 < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160728'
  end

  def down
    build_calculator '20160722'
  end

end
