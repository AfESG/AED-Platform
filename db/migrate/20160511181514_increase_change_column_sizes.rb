require 'sql_helper'

class IncreaseChangeColumnSizes < ActiveRecord::Migration

  include SqlHelper

  def up
    preflush_calculator '20160511'
    change_column :changes, :replaced_strata, :string, :limit => 512
    change_column :changes, :new_strata, :string, :limit => 512
    build_calculator '20160511'
  end

  def down

  end

end
