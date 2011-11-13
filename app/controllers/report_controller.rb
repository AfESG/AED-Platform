class ReportController < ApplicationController

  def species
    @species = params[:species].gsub('_',' ')
  end

  def year
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
  end

  def continent
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
    @continent = params[:continent]
    begin
      @summary_totals_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.summary_totals_by_continent where "CONTINENT"='#{@continent}'
      SQL
    rescue
      @summary_totals_by_continent = nil
    end

    begin
      @summary_sums_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.summary_sums_by_continent where "CONTINENT"='#{@continent}'
      SQL
    rescue
      @summary_sums_by_continent = nil
    end

    begin
      @area_of_range_covered_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_by_continent where "CONTINENT"='#{@continent}'
      SQL

      @area_of_range_covered_sum_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_sum_by_continent where "CONTINENT"='#{@continent}'
      SQL
    rescue
      @area_of_range_covered_by_continent = nil
      @area_of_range_covered_sum_by_continent = nil
    end

    begin
      @regions = ActiveRecord::Base.connection.execute <<-SQL
        select distinct "REGION" from aed2007."Country" where "REGION"!='';
      SQL
    rescue
      @regions = nil
    end
  end

  def region
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    begin
      @summary_totals_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.summary_totals_by_region where "REGION"='#{@region}'
      SQL
    rescue
      @summary_totals_by_region = nil
    end

    begin
      @summary_sums_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.summary_sums_by_region where "REGION"='#{@region}'
      SQL
    rescue
      @summary_sums_by_region = nil
    end

    begin
      @causes_of_change_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_by_region where "REGION"='#{@region}'
      SQL
    rescue
      @causes_of_change_by_region = nil
    end

    begin
      @causes_of_change_sums_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_sums_by_region where "REGION"='#{@region}'
      SQL
    rescue
      @causes_of_change_sums_by_region = nil
    end

    begin
      @area_of_range_covered_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_by_region where "REGION"='#{@region}'
      SQL

      @area_of_range_covered_sum_by_region = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_sum_by_region where "REGION"='#{@region}'
      SQL
    rescue
      @area_of_range_covered_by_region = nil
      @area_of_range_covered_sum_by_region = nil
    end

    begin
      @countries = ActiveRecord::Base.connection.execute <<-SQL
        select distinct "CNTRYNAME" from aed2007."Country" where "REGION"='#{@region}' order by "CNTRYNAME";
      SQL
    rescue
      @countries = nil
    end
  end

  def country
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')

    begin
      ccodes = ActiveRecord::Base.connection.execute <<-SQL
        SELECT "CCODE"
        FROM aed#{@year}."Country" where "CNTRYNAME"='#{@country}'
      SQL
      @ccode = ccodes[0]['CCODE']
    rescue
      @ccode = @country
    end

    begin
      @causes_of_change_by_country = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_by_country where ccode='#{@ccode}'
      SQL
    rescue
      @causes_of_change_by_country = nil
    end

    begin
      @causes_of_change_sums_by_country = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_sums_by_country where ccode='#{@ccode}'
      SQL
    rescue
      @causes_of_change_sums_by_country = nil
    end

    @summary_totals_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.summary_totals_by_country where ccode='#{@ccode}'
    SQL

    @summary_sums_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.summary_sums_by_country where ccode='#{@ccode}'
    SQL

    begin
      @area_of_range_covered_by_country = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_by_country where ccode='#{@ccode}'
      SQL

      @area_of_range_covered_sum_by_country = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.area_of_range_covered_sum_by_country where ccode='#{@ccode}'
      SQL
    rescue
      @area_of_range_covered_by_country = nil
      @area_of_range_covered_sum_by_country = nil
    end

    @elephant_estimates_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.elephant_estimates_by_country where ccode='#{@ccode}'
    SQL

  end

  def survey
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
    @survey = params[:survey]
    survey_zones = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.elephant_estimates_by_country where "INPCODE"='#{@survey}'
    SQL
    survey_zones.each do |survey_zone|
      @survey_zone = survey_zone
      break
    end
  end
end
