require 'sql_helper'

class Run0606Calc < ActiveRecord::Migration

  include SqlHelper

  def change
    build_calculator '20160606'
  end

end
