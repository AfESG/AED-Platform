module DppsCountryHelper
  def get_country_values(country, filter, year)
    baseline_total = execute <<-SQL, country
      select a.comparison_year, sum(definite) definite, sum(probable) probable, sum(possible) possible,
        sum(speculative) speculative
      from analyses a
      join dpps_sums_country_category d ON a.analysis_name = d.analysis_name and a.comparison_year = d.analysis_year
      where a.analysis_name = '#{filter}' and a.analysis_year='#{year}' and country=?
      group by a.comparison_year;
    SQL

    elephant_estimates_by_country = execute <<-SQL, country
      select
        e.sort_key,
        e.population,
        e.replacement_name,
        e.site_name,
        e.stratum_name,
        e.population_variance,
        CASE WHEN reason_change='NC' THEN
          '-'
        ELSE
          reason_change
        END as "ReasonForChange",
        e.population_submission_id,
        e.input_zone_id method_and_quality,
        e.category "CATEGORY",
        e.completion_year "CYEAR",
        e.population_estimate "ESTIMATE",
        CASE WHEN e.population_upper_confidence_limit IS NOT NULL THEN
          CASE WHEN e.estimate_type='O' THEN
            to_char(e.population_upper_confidence_limit-e.population_estimate,'999,999') || '*'
          ELSE
            to_char(e.population_upper_confidence_limit-e.population_estimate,'999,999')
          END
        WHEN e.population_confidence_interval IS NOT NULL THEN
          to_char(ROUND(e.population_confidence_interval),'999,999')
        ELSE
          ''
        END "CL95",
        CASE
            WHEN e.category IN ('J', 'K') THEN GREATEST(e.population_estimate - (sqrt(e.population_variance) * 1.96), 0)
            WHEN e.category IN ('B', 'L') THEN GREATEST(e.population_estimate - (sqrt(e.population_variance) * 1.96) - (sqrt(((e.population_estimate - e.population_lower_confidence_limit) / 1.96) ^ 2) * 1.96), 0)
        END as "LOWER_BOUND",
        CASE
            WHEN e.category IN ('J', 'K') THEN e.population_estimate + (sqrt(e.population_variance) * 1.96)
            WHEN e.category IN ('B', 'L') THEN e.population_estimate + (sqrt(e.population_variance) * 1.96) - (sqrt(((e.population_upper_confidence_limit - e.population_estimate) / 1.96) ^ 2) * 1.96)
        END as "UPPER_BOUND",
        e.short_citation "REFERENCE",
        round(log((((definite+probable+0.001)/(definite+probable+possible+speculative+0.001))+1)/(a.area_sqkm/rm.range_area))) "PFS",
        definite+probable "DP",
        definite+probable+possible+speculative "DPPS",
        rm.range_area "RA",
        a.area_sqkm "CALC_SQKM",
        e.stratum_area "AREA_SQKM",
        CASE WHEN longitude<0 THEN
          to_char(abs(longitude),'990D9')||'W'
        WHEN longitude=0 THEN
          '0.0'
        ELSE
          to_char(abs(longitude),'990D9')||'E'
        END "LON",
        CASE WHEN latitude<0 THEN
          to_char(abs(latitude),'990D9')||'S'
        WHEN latitude=0 THEN
          '0.0'
        ELSE
          to_char(abs(latitude),'990D9')||'N'
        END "LAT"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
          and e.category = d.category
        join estimate_locator_areas a on e.input_zone_id = a.input_zone_id
          and e.analysis_name = a.analysis_name
          and e.analysis_year = a.analysis_year
        join surveytypes t on t.category = e.category
        join population_submissions on e.population_submission_id = population_submissions.id
        join regional_range_table rm on e.country = rm.country AND
          e.analysis_name = rm.analysis_name AND e.analysis_year = rm.analysis_year
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and e.country=?
      order by e.sort_key, e.site_name, e.stratum_name
    SQL

    coverage_table = execute <<-SQL, country
      SELECT * from survey_range_intersection_metrics where
        country=? and analysis_name = '#{filter}'
    SQL

    elephant_estimate_groups = []

    group = []
    current_replacement_name = elephant_estimates_by_country[0]['replacement_name']
    elephant_estimates_by_country.each do |row|
      puts row['sort_key']
      if row['replacement_name'] == current_replacement_name
        group << row
      else
        elephant_estimate_groups << group
        group = []
        group << row
        current_replacement_name = row['replacement_name']
      end
    end
    elephant_estimate_groups << group

    causes_of_change_by_country = execute <<-SQL, country
      SELECT *
      FROM causes_of_change_by_country_scaled where country=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_country = execute <<-SQL, country
      SELECT *
      FROM causes_of_change_sums_by_country_scaled where country=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_by_country_u = execute <<-SQL, country
      SELECT *
      FROM causes_of_change_by_country where country=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_country_u = execute <<-SQL, country
      SELECT *
      FROM causes_of_change_sums_by_country where country=?
        and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    area_of_range_covered_by_country = execute <<-SQL, country, country
      SELECT surveytype, ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM area_of_range_covered where country=? and analysis_name = '#{filter}' and analysis_year = '#{year}'
      union
      SELECT 'Unassessed Range', ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM area_of_range_covered_unassessed where country=? and analysis_name = '#{filter}' and analysis_year = '#{year}'
      order by surveytype
    SQL

    area_of_range_covered_sum_by_country = execute <<-SQL, country
      SELECT ROUND(known) known, ROUND(possible) possible, ROUND(total) total
      FROM area_of_range_covered_totals where country=? and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    {
        baseline_total: baseline_total,
        elephant_estimates_by_country: elephant_estimates_by_country,
        coverage_table: coverage_table,
        elephant_estimate_groups: elephant_estimate_groups,
        causes_of_change_by_country: causes_of_change_by_country,
        causes_of_change_sums_by_country: causes_of_change_sums_by_country,
        causes_of_change_by_country_u: causes_of_change_by_country_u,
        causes_of_change_sums_by_country_u: causes_of_change_sums_by_country_u,
        area_of_range_covered_by_country: area_of_range_covered_by_country,
        area_of_range_covered_sum_by_country: area_of_range_covered_sum_by_country
    }
  end
end
