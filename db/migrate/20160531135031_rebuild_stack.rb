require 'sql_helper'

include SqlHelper

class RebuildStack < ActiveRecord::Migration
  def change
    build_calculator '20160524'
  end
end
