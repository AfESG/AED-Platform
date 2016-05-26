class Continent < ActiveRecord::Base
  include AltDppsHelper
  include DppsContinentHelper
  include TotalizerHelper

  has_many :regions

  def countries
    Country.where(region: self.regions)
  end

  def dpps(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name
    {
        continent: name,
        year: year,
        analysis_name: filter,
        continent_totals: execute(totalizer('1=1', filter, year))
    }.merge(get_continent_values(name, filter, year))
  end

  def add(year)
    filter = Analysis.find_by_analysis_year(year).analysis_name
    args = ['1=1', year, filter]
    {
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
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
