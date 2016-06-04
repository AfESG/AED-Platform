require 'sql_helper'

class GeneralStatisticsSupport < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160604'
  end

  def down
    build_calculator '20160531'
  end

end
