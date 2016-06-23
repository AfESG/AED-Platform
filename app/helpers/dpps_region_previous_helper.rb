module DppsRegionPreviousHelper
  def get_region_previous_values(region, year)
    db = "aed#{year}"

    begin
      summary_totals_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.summary_totals_by_region where "REGION"=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      summary_sums_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.summary_sums_by_region where "REGION"=?
      SQL
    rescue
      summary_sums_by_region = nil
    end

    begin
      causes_of_change_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.causes_of_change_by_region where "REGION"=?
      SQL
    rescue
      causes_of_change_by_region = nil
    end

    begin
      causes_of_change_sums_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.causes_of_change_sums_by_region where "REGION"=?
      SQL
    rescue
      causes_of_change_sums_by_region = nil
    end

    begin
      area_of_range_covered_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.area_of_range_covered_by_region where "REGION"=?
      SQL

      area_of_range_covered_sum_by_region = execute <<-SQL, region
      SELECT *
      FROM #{db}.area_of_range_covered_sum_by_region where "REGION"=?
      SQL
    rescue
      area_of_range_covered_by_region = nil
      area_of_range_covered_sum_by_region = nil
    end

    begin
      countries = execute <<-SQL, region
      SELECT *
      FROM #{db}.country_and_regional_totals_and_data_quality where "REGION"=?;
      SQL
    rescue
      countries = nil
    end

    begin
      countries_sum = execute <<-SQL, region
      SELECT *
      FROM #{db}.country_and_regional_totals_and_data_quality_sum where "REGION"=?;
      SQL
    rescue
      countries_sum = nil
    end
    
    {
        summary_totals_by_region: summary_totals_by_region,
        summary_sums_by_region: summary_sums_by_region,
        causes_of_change_by_region: causes_of_change_by_region,
        causes_of_change_sums_by_region: causes_of_change_sums_by_region,
        area_of_range_covered_by_region: area_of_range_covered_by_region,
        area_of_range_covered_sum_by_region: area_of_range_covered_sum_by_region,
        countries: countries,
        countries_sum: countries_sum
    }
  end
end
