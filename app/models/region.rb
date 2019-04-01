class Region < ActiveRecord::Base
  include AltDppsHelper
  include DppsRegionHelper
  include TotalizerHelper
  include DppsRegionPreviousHelper
  include NarrativeBoilerplates

  belongs_to :continent
  has_many :countries

  def to_s
    name
  end

  def dpps(year)
    if AedLegacy.legacy_year?(year)
      values = {
          region: name,
          year: year,
      }.merge(get_region_previous_values(name, year))
    else
      filter = Analysis.find_by_analysis_year(year).analysis_name rescue nil
      values = {
          region: name,
          year: year,
          analysis_name: filter,
          region_totals: execute(totalizer("region='#{name}'", filter, year))
      }.merge(get_region_values(name, filter, year))
    end
    values[:countries] = values[:countries].map do |country|
      country['iso_code'] = Country.find_by_name(country['CNTRYNAME']).iso_code
      country
    end
    values
  end

  def add(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name rescue nil
    args = ["region='#{name}'", year, filter]
    values = {
        region: name,
        year: year,
        assessed_range: assessed_range(year),
        summary_totals: execute(alt_dpps(*args)),
        summary_sums: execute(alt_dpps_totals(*args)),
        areas: execute(alt_dpps_region_area(*args)),
        countries: execute(alt_dpps_region_stats(*args)),
        countries_sums: execute(alt_dpps_region_stats_sums(*args)),
        causes_of_change: execute(alt_dpps_causes_of_change(*args)),
        causes_of_change_sums: execute(alt_dpps_causes_of_change_sums(*args)),
        areas_by_reason: execute(alt_dpps_region_area_by_reason(*args))
    }
    values[:countries] = values[:countries].map do |country|
      country['iso_code'] = Country.find_by_name(country['country']).iso_code
      country
    end
    values
  end

  def geojson_map_simple(simplify = 0.0)
    if name == 'Eastern Africa'
      # subtract Sudan
      sql = <<sql
WITH geoms AS (
    SELECT
      cc.name,
      c.geom
    FROM countries cc
      JOIN country c ON (cc.iso_code = c.ccode)
    WHERE cc.region_id = 3 AND cc.name != 'Sudan'
)
SELECT ST_AsGeoJSON(
  ST_SimplifyPreserveTopology(ST_Union(ST_SnapToGrid(geom, 0.0001)), ?), 10) AS geo
FROM geoms WHERE 'Eastern Africa' = ?;
sql
    else
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geom, ?), 10) as "geo" FROM region WHERE region = ?'
    end
    execute(sql, simplify, name).first['geo']
  end

  def geojson_map
    if name == 'Eastern Africa'
      # subtract Sudan
      sql = <<sql
WITH geoms AS (
    SELECT
      cc.name,
      c.geom
    FROM countries cc
      JOIN country c ON (cc.iso_code = c.ccode)
    WHERE cc.region_id = 3 AND cc.name != 'Sudan'
)
SELECT ST_AsGeoJSON(ST_Union(ST_SnapToGrid(geom, 0.0001)), 10) AS geo
FROM geoms WHERE 'Eastern Africa' = ?;
sql
    else
      sql = 'SELECT ST_AsGeoJSON(geom, 10) as "geo" FROM region WHERE region = ?'
    end
    execute(sql, name).first['geo']
  end

  def assessed_range(year)
    sql = 'SELECT range_assessed FROM regional_range_totals WHERE region = ? AND analysis_year = ? LIMIT 1'
    execute(sql, name, year).first['range_assessed'] rescue nil
  end

  def estimates
    sql = <<-SQL
SELECT
  analysis_year,
  "ESTIMATE" AS estimate
FROM estimate_factors_analyses_categorized_totals_region_for_add
WHERE region = ?
ORDER BY analysis_year;
    SQL
    execute(sql, name).to_a
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
