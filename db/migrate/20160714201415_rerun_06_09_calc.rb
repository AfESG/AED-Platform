require 'sql_helper'

class Rerun0609Calc < ActiveRecord::Migration
  include SqlHelper

  def change
    build_calculator '20160609'
  end
end
