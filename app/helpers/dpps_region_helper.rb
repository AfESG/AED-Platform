module DppsRegionHelper
  def get_region_values(region, filter, year)
    baseline_total = execute <<-SQL, region
      select a.comparison_year, sum(definite) definite, sum(probable) probable, sum(possible) possible,
        sum(speculative) speculative
      from analyses a
      join dpps_sums_region_category d ON a.analysis_name = d.analysis_name AND a.comparison_year = d.analysis_year
      where a.analysis_name = '#{filter}' and a.analysis_year='#{year}' and region=?
      group by a.comparison_year;
    SQL

    countries = execute <<-SQL, region
      select
        continent "CONTINENT",
        d.region "REGION",
        d.country "CNTRYNAME",
        definite "DEFINITE",
        possible "POSSIBLE",
        probable "PROBABLE",
        speculative "SPECUL",
        ROUND(rm.range_area) "RANGEAREA",
        ROUND(rm.percent_regional_range) "RANGEPERC",
        ROUND(rm.percent_range_assessed) "SURVRANGPERC",
        to_char(((definite+probable)/(definite+probable+possible+speculative))*(rm.range_assessed/range_area),'999999D99') "INFQLTYIDX",
        round(log((((definite+probable)/(definite+probable+possible+speculative))*(rm.range_assessed/range_area)+1)/(rm.range_area/ca.continental_range))) "PFS"
      from
        (select distinct continental_range from continental_range_table) ca,
        dpps_sums_country d
        join regional_range_table rm on d.country = rm.country AND rm.analysis_name = d.analysis_name AND rm.analysis_year = d.analysis_year
        where d.analysis_name = '#{filter}' and d.analysis_year = '#{year}' and d.region=?;
    SQL

    countries_sum = execute <<-SQL, region
      select
        d.continent "CONTINENT",
        d.region "REGION",
        definite "DEFINITE",
        possible "POSSIBLE",
        probable "PROBABLE",
        speculative "SPECUL",
        ROUND(rm.range_area) "RANGEAREA",
        ROUND(rm.percent_regional_range) "RANGEPERC",
        ROUND(rm.percent_range_assessed) "SURVRANGPERC",
        to_char(((definite+probable)/(definite+probable+possible+speculative))*(rm.range_assessed/range_area),'999999D99') "INFQLTYIDX",
        round(log((((definite+probable)/(definite+probable+possible+speculative))*(rm.range_assessed/range_area)+1)/(rm.range_area/ca.continental_range))) "PFS"
       from
        (select distinct continental_range from continental_range_table) ca,
        dpps_sums_region d
        join regional_range_totals rm on d.region = rm.region AND rm.analysis_name = d.analysis_name AND rm.analysis_year = d.analysis_year
        where d.analysis_name = '#{filter}' and d.analysis_year = '#{year}' and d.region=?;
    SQL
    causes_of_change_by_region = execute <<-SQL, region
      SELECT *
      FROM causes_of_change_by_region_scaled where region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_region = execute <<-SQL, region
      SELECT *
      FROM causes_of_change_sums_by_region_scaled where region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_by_region_u = execute <<-SQL, region
      SELECT *
      FROM causes_of_change_by_region where region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_region_u = execute <<-SQL, region
      SELECT *
      FROM causes_of_change_sums_by_region where region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    area_of_range_covered_by_region = execute <<-SQL, region, region
      SELECT surveytype, ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM regional_area_of_range_covered
      WHERE region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
      union
      SELECT 'Unassessed Range', ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM regional_area_of_range_covered_unassessed
      WHERE region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
      order by surveytype
    SQL

    area_of_range_covered_sum_by_region = execute <<-SQL, region
      SELECT ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM regional_area_of_range_covered_totals
      where region=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    {
        baseline_total: baseline_total,
        countries: countries,
        countries_sum: countries_sum,
        causes_of_change_by_region: causes_of_change_by_region,
        causes_of_change_sums_by_region: causes_of_change_sums_by_region,
        causes_of_change_by_region_u: causes_of_change_by_region_u,
        causes_of_change_sums_by_region_u: causes_of_change_sums_by_region_u,
        area_of_range_covered_by_region: area_of_range_covered_by_region,
        area_of_range_covered_sum_by_region: area_of_range_covered_sum_by_region
    }
  end
end
