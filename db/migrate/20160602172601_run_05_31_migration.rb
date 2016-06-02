require 'sql_helper'

class Run0531Migration < ActiveRecord::Migration

  include SqlHelper

  def change
    build_calculator '20160531'
  end

end
