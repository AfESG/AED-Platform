module DppsContinentHelper
  def get_continent_values(continent, filter, year)
    baseline_total = execute <<-SQL, continent
        select sum(definite) definite, sum(probable) probable, sum(possible) possible,
          sum(speculative) speculative
        from analyses a
        join dpps_sums_continent_category d ON a.analysis_name = d.analysis_name AND a.comparison_year = d.analysis_year
        where a.analysis_name = '#{filter}' and a.analysis_year='#{year}' and continent=?;
    SQL

    begin
      regions = nil
      regions = execute <<-SQL, continent
          select
            d.continent "CONTINENT",
            d.region "REGION",
            definite "DEFINITE",
            possible "POSSIBLE",
            probable "PROBABLE",
            speculative "SPECUL",
            ROUND(cm.range_area) "RANGEAREA",
            ROUND(cm.percent_continental_range) "RANGEPERC",
            ROUND(cm.percent_range_assessed) "SURVRANGPERC",
            to_char(((definite+probable)/(definite+probable+possible+speculative))*(cm.range_assessed/range_area),'999999D99') "INFQLTYIDX",
            round(ln((((definite+probable)/(definite+probable+possible+speculative))*(cm.range_assessed/range_area)+1)/(cm.range_area/cm.continental_range))) "PFS"
          from
            dpps_sums_region d
            join continental_range_table cm on d.region = cm.region AND cm.analysis_name = d.analysis_name AND cm.analysis_year = d.analysis_year
            where d.analysis_name = '#{filter}' and d.analysis_year = '#{year}';
      SQL
      regions_sum = execute <<-SQL, continent
          select
            d.continent "CONTINENT",
            definite "DEFINITE",
            possible "POSSIBLE",
            probable "PROBABLE",
            speculative "SPECUL",
            ROUND(ct.range_area) "RANGEAREA",
            ROUND(ct.percent_continental_range) "RANGEPERC",
            ROUND(ct.percent_range_assessed) "SURVRANGPERC",
            to_char(((definite+probable)/(definite+probable+possible+speculative))*(ct.range_assessed/range_area),'999999D99') "INFQLTYIDX",
            0 "PFS"
          from
            dpps_sums_continent d
            join continental_range_totals ct on ct.continent = d.continent AND ct.analysis_name = d.analysis_name AND ct.analysis_year = d.analysis_year
            where d.analysis_name = '#{filter}' and d.analysis_year = '#{year}';
      SQL
    rescue
      regions = nil
    end

    causes_of_change_by_continent_u = execute <<-SQL, continent
        SELECT *
        FROM causes_of_change_by_continent where continent=?
          and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_continent_u = execute <<-SQL, continent
        SELECT *
        FROM causes_of_change_sums_by_continent where continent=?
          and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_by_continent = execute <<-SQL, continent
        SELECT *
        FROM causes_of_change_by_continent_scaled where continent=?
          and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    causes_of_change_sums_by_continent = execute <<-SQL, continent
        SELECT *
        FROM causes_of_change_sums_by_continent_scaled where continent=?
          and analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    area_of_range_covered_by_continent = execute <<-SQL
        SELECT surveytype, ROUND(known) known, ROUND(possible) possible, ROUND(total) total
        FROM continental_area_of_range_covered
        WHERE analysis_name = '#{filter}' and analysis_year = '#{year}'
        union
        SELECT 'Unassessed Range', ROUND(known) known, ROUND(possible) possible, ROUND(total) total
        FROM continental_area_of_range_covered_unassessed
        WHERE analysis_name = '#{filter}' and analysis_year = '#{year}'
        order by surveytype
    SQL

    area_of_range_covered_sum_by_continent = execute <<-SQL
        SELECT ROUND(known) known, ROUND(possible) possible, ROUND(total) total
        FROM continental_area_of_range_covered_totals
        WHERE analysis_name = '#{filter}' and analysis_year = '#{year}'
    SQL

    {
        baseline_total: baseline_total,
        regions: regions,
        regions_sum: regions_sum,
        causes_of_change_by_continent_u: causes_of_change_by_continent_u,
        causes_of_change_sums_by_continent_u: causes_of_change_sums_by_continent_u,
        causes_of_change_by_continent: causes_of_change_by_continent,
        causes_of_change_sums_by_continent: causes_of_change_sums_by_continent,
        area_of_range_covered_by_continent: area_of_range_covered_by_continent,
        area_of_range_covered_sum_by_continent: area_of_range_covered_sum_by_continent
    }
  end
end
