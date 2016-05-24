require 'sql_helper'

class ModeledExtrapolationSurvey < ActiveRecord::Migration

  include SqlHelper

  def up
    build_calculator '20160524'
  end

  def down
    build_calculator '20160518'
  end

end
