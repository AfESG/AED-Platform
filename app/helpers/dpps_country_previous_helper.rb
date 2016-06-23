module DppsCountryPreviousHelper
  def get_country_previous_values(country, year)
    db = "aed#{year}"

    begin
      ccodes = execute <<-SQL, country
        SELECT "CCODE"
        FROM #{db}."Country" where "CNTRYNAME"=?
      SQL
      ccode = ccodes[0]['CCODE']
    rescue
      ccode = country
    end

    begin
      causes_of_change_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.causes_of_change_by_country where ccode=?
      SQL
    rescue
      causes_of_change_by_country = nil
    end

    begin
      causes_of_change_sums_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.causes_of_change_sums_by_country where ccode=?
      SQL
    rescue
      causes_of_change_sums_by_country = nil
    end

    begin
      summary_totals_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.summary_totals_by_country where ccode=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      summary_sums_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.summary_sums_by_country where ccode=?
      SQL
    rescue
      summary_sums_by_country = nil
    end

    begin
      area_of_range_covered_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.area_of_range_covered_by_country where ccode=?
      SQL

      area_of_range_covered_sum_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.area_of_range_covered_sum_by_country where ccode=?
      SQL
    rescue
      area_of_range_covered_by_country = nil
      area_of_range_covered_sum_by_country = nil
    end

    begin
      elephant_estimates_by_country = execute <<-SQL, ccode
        SELECT *
        FROM #{db}.elephant_estimates_by_country where ccode=?
      SQL
    rescue
      elephant_estimates_by_country = nil
    end

    {
        causes_of_change_by_country: causes_of_change_by_country,
        causes_of_change_sums_by_country: causes_of_change_sums_by_country,
        summary_totals_by_country: summary_totals_by_country,
        summary_sums_by_country: summary_sums_by_country,
        area_of_range_covered_by_country: area_of_range_covered_by_country,
        area_of_range_covered_sum_by_country: area_of_range_covered_sum_by_country,
        elephant_estimates_by_country: elephant_estimates_by_country
    }
  end
end
