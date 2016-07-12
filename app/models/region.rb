class Region < ActiveRecord::Base
  include AltDppsHelper
  include DppsRegionHelper
  include TotalizerHelper
  include DppsRegionPreviousHelper

  belongs_to :continent
  has_many :countries

  def dpps(year)
    if year.to_i != 2013
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

  def geojson_map(simplify = 0.0)
    sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geom, ?), 10) as "geo" FROM region WHERE region = ?'
    execute(sql, simplify, name).first['geo']
  end

  def assessed_range(year)
    sql = 'SELECT range_assessed FROM regional_range_totals WHERE region = ? AND analysis_year = ? LIMIT 1'
    execute(sql, name, year).first['range_assessed']
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
