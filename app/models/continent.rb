class Continent < ActiveRecord::Base
  include AltDppsHelper
  include DppsContinentHelper
  include TotalizerHelper
  include DppsContinentPreviousHelper
  include NarrativeBoilerplates

  has_many :regions

  def to_s
    name
  end

  def countries
    Country.where(region: self.regions)
  end

  def dpps(year)
    if year.to_i < 2013
      values = {
          continent: name,
          year: year
      }.merge(get_continent_previous_values(name, year))
    else
      filter = Analysis.find_by_analysis_year(year).analysis_name
      values = {
          continent: name,
          year: year,
          analysis_name: filter,
          continent_totals: execute(totalizer('1=1', filter, year))
      }.merge(get_continent_values(name, filter, year))
    end
    values[:regions] = values[:regions].map do |region|
      region['id'] = Region.find_by_name(region['REGION']).id
      region
    end
    values
  end

  def add(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name
    args = ['1=1', year, filter]
    values = {
        continent: name,
        year: year,
        analysis_name: filter,
        summary_totals: execute(alt_dpps(*args)),
        summary_sums: execute(alt_dpps_totals(*args)),
        areas: execute(alt_dpps_continent_area(*args)),
        regions: execute(alt_dpps_continental_stats(*args)),
        regions_sums: execute(alt_dpps_continental_stats_sums(*args)),
        causes_of_change: execute(alt_dpps_causes_of_change(*args)),
        causes_of_change_sums: execute(alt_dpps_causes_of_change_sums(*args)),
        areas_by_reason: execute(alt_dpps_continent_area_by_reason(*args))
    }
    values[:regions] = values[:regions].map do |region|
      region['id'] = Region.find_by_name(region['region']).id
      region
    end
    values
  end

  def geojson_map_simple(simplify = 0.0)
    sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geom, ?), 10) as "geo" FROM continent WHERE continent = ?'
    execute(sql, simplify, name).first['geo']
  end

  def geojson_map
    sql = 'SELECT ST_AsGeoJSON(geom, 10) as "geo" FROM continent WHERE continent = ?'
    execute(sql, name).first['geo']
  end

  def estimates
    sql = <<-SQL
SELECT
  analysis_year,
  "ESTIMATE" AS estimate
FROM estimate_factors_analyses_categorized_totals_continent_for_add
WHERE continent = 'Africa'
ORDER BY analysis_year;
    SQL
    execute(sql).to_a
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
