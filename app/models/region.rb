class Region < ActiveRecord::Base
  include AltDppsHelper
  include DppsRegionHelper
  include TotalizerHelper

  belongs_to :continent
  has_many :countries

  def dpps(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name rescue nil
    {
        region: name,
        year: year,
        analysis_name: filter,
        region_totals: execute(totalizer("region='#{name}'", filter, year))
    }.merge(get_region_values(name, filter, year))
  end

  def add(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name rescue nil
    args = ["region='#{name}'", year, filter]
    {
        region: name,
        year: year,
        summary_totals: execute(alt_dpps(*args)),
        summary_sums: execute(alt_dpps_totals(*args)),
        areas: execute(alt_dpps_region_area(*args)),
        countries: execute(alt_dpps_region_stats(*args)),
        country_sums: execute(alt_dpps_region_stats_sums(*args)),
        causes_of_change: execute(alt_dpps_causes_of_change(*args)),
        causes_of_change_sums: execute(alt_dpps_causes_of_change_sums(*args)),
        areas_by_reason: execute(alt_dpps_region_area_by_reason(*args))
    }
  end

  def geojson_map
    execute('SELECT ST_AsGeoJSON(geom) as "geo" FROM region WHERE region = ?', name).first['geo']
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
