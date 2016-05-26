class StripSpacesFromPopulations < ActiveRecord::Migration
  def up
    execute 'update changes set population = trim(both from population);'
  end
  def down
  end
end
