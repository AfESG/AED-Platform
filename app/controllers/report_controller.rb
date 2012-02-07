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
      @causes_of_change_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_by_continent where "CONTINENT"='#{@continent}'
      SQL
    rescue
      @causes_of_change_by_continent = nil
    end

    begin
      @causes_of_change_sums_by_continent = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.causes_of_change_sums_by_continent where "CONTINENT"='#{@continent}'
      SQL
    rescue
      @causes_of_change_sums_by_continent = nil
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
        SELECT *
        FROM aed#{@year}.continental_and_regional_totals_and_data_quality where "CONTINENT"='#{@continent}';
      SQL
    rescue
      @regions = nil
    end

    begin
      @regions_sum = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.continental_and_regional_totals_and_data_quality_sum where "CONTINENT"='#{@continent}';
      SQL
    rescue
      @regions_sum = nil
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
        SELECT *
        FROM aed#{@year}.country_and_regional_totals_and_data_quality where "REGION"='#{@region}';
      SQL
    rescue
      @countries = nil
    end

    begin
      @countries_sum = ActiveRecord::Base.connection.execute <<-SQL
        SELECT *
        FROM aed#{@year}.country_and_regional_totals_and_data_quality_sum where "REGION"='#{@region}';
      SQL
    rescue
      @countries_sum = nil
    end
  end

  def country
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')

    conn = ActiveRecord::Base.connection.instance_variable_get("@connection")

    begin
      ccodes = ActiveRecord::Base.connection.execute <<-SQL
        SELECT "CCODE"
        FROM aed#{@year}."Country" where "CNTRYNAME"='#{conn.escape(@country)}'
      SQL
      @ccode = ccodes[0]['CCODE']
    rescue => e
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

  helper_method :narrative, :footnote

  def report_narrative
    if @report_narrative.nil?
      @report_narrative = ReportNarrative.where(:uri => request.path[8..-1]).first
    end
    if @report_narrative.nil?
      @report_narrative = ReportNarrative.new
    end
    return @report_narrative
  end

  def narrative
    narrative = report_narrative.narrative
    if narrative.nil?
      narrative = ''
    else
      narrative = "<div class='report_narrative_narrative'>#{narrative}</div>"
    end
  end

  def footnote
    note = report_narrative.footnote
    if note.nil?
      note = ''
    else
      note = "<div class='report_narrative_footnote'>#{note}</div>"
    end
    if !current_user.nil? and current_user.admin?
      result = render_to_string :partial => "edit_narrative_links", :locals => {:report_narrative => report_narrative}
      note << result
    end
    note
  end

end
