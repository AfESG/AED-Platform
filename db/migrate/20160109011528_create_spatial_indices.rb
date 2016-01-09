class CreateSpatialIndices < ActiveRecord::Migration
  def up
    execute 'create index si_range_geometry on range_geometries using gist (geometry)'
    execute 'create index si_survey_geometry on survey_geometries using gist (geometry)'
    execute 'create index si_survey_geom on survey_geometries using gist (geom)'
    execute 'create index si_country_geom on country using gist (geom)'
    execute 'END'
    execute 'vacuum analyze'
    execute 'BEGIN'
  end
end
