class ResetPopulationSortKeys < ActiveRecord::Migration
  def up
    execute 'update changes set sort_key = population || replacement_name;'
  end
  def down
  end
end
