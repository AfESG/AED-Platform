require 'sql_helper'

class Run0722Calc < ActiveRecord::Migration

  include SqlHelper

  def change
    build_calculator '20160722'
  end

end
