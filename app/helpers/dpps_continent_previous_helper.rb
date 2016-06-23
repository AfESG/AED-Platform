module DppsContinentPreviousHelper
  def get_continent_previous_values(continent, year)
    db = "aed#{year}"

    begin
      summary_totals_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.summary_totals_by_continent where "CONTINENT"=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      summary_sums_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.summary_sums_by_continent where "CONTINENT"=?
      SQL
    rescue
      summary_sums_by_continent = nil
    end

    begin
      causes_of_change_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.causes_of_change_by_continent where "CONTINENT"=?
      SQL
    rescue
      causes_of_change_by_continent = nil
    end

    begin
      causes_of_change_sums_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.causes_of_change_sums_by_continent where "CONTINENT"=?
      SQL
    rescue
      causes_of_change_sums_by_continent = nil
    end

    begin
      area_of_range_covered_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.area_of_range_covered_by_continent where "CONTINENT"=?
      SQL

      area_of_range_covered_sum_by_continent = execute <<-SQL, continent
        SELECT *
        FROM #{db}.area_of_range_covered_sum_by_continent where "CONTINENT"=?
      SQL
    rescue
      area_of_range_covered_by_continent = nil
      area_of_range_covered_sum_by_continent = nil
    end

    begin
      regions = execute <<-SQL, continent
        SELECT *
        FROM #{db}.continental_and_regional_totals_and_data_quality where "CONTINENT"=?;
      SQL
    rescue
      regions = nil
    end

    begin
      regions_sum = execute <<-SQL, continent
        SELECT *
        FROM #{db}.continental_and_regional_totals_and_data_quality_sum where "CONTINENT"=?;
      SQL
    rescue
      regions_sum = nil
    end

    {
        summary_totals_by_continent: summary_totals_by_continent,
        summary_sums_by_continent: summary_sums_by_continent,
        causes_of_change_by_continent: causes_of_change_by_continent,
        causes_of_change_sums_by_continent: causes_of_change_sums_by_continent,
        area_of_range_covered_by_continent: area_of_range_covered_by_continent,
        area_of_range_covered_sum_by_continent: area_of_range_covered_sum_by_continent,
        regions: regions,
        regions_sum: regions_sum
    }
  end
end
