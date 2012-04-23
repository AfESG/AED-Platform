class ReportController < ApplicationController

  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def references
    @references = execute <<-SQL
      SELECT *
      FROM aed2007."References"
      order by "Authors"
    SQL
  end

  def species
    @species = params[:species].gsub('_',' ')
  end

  def year
    @species = params[:species].gsub('_',' ')
    @year = params[:year]
  end

  before_filter :authenticate_user!, :only => :mike_continent

  def mike_continent
    return unless current_user.admin?
    @species = 'Loxodonta africana'
    @year = 2012
    @continent = 'Africa'
    @summary_totals_by_continent = execute <<-SQL
select 'Africa' "CONTINENT", e.category "CATEGORY", surveytype "SURVEYTYPE", sum(definite) "DEFINITE", sum(probable) "PROBABLE", sum(possible) "POSSIBLE", sum(speculative) "SPECUL" from estimate_dpps e join (
select input_zone_id from estimates join population_submissions on population_submission_id = population_submissions.id join submissions on submission_id = submissions.id where is_mike_site=true
) f on f.input_zone_id = e.input_zone_id join surveytypes t on t.category = e.category group by e.category, surveytype order by e.category;
    SQL
  end

  def continent
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    db = "aed#{@year}"
    @continent = params[:continent]
    begin
      @summary_totals_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.summary_totals_by_continent where "CONTINENT"=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      @summary_sums_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.summary_sums_by_continent where "CONTINENT"=?
      SQL
    rescue
      @summary_sums_by_continent = nil
    end

    begin
      @causes_of_change_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.causes_of_change_by_continent where "CONTINENT"=?
      SQL
    rescue
      @causes_of_change_by_continent = nil
    end

    begin
      @causes_of_change_sums_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.causes_of_change_sums_by_continent where "CONTINENT"=?
      SQL
    rescue
      @causes_of_change_sums_by_continent = nil
    end

    begin
      @area_of_range_covered_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.area_of_range_covered_by_continent where "CONTINENT"=?
      SQL

      @area_of_range_covered_sum_by_continent = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.area_of_range_covered_sum_by_continent where "CONTINENT"=?
      SQL
    rescue
      @area_of_range_covered_by_continent = nil
      @area_of_range_covered_sum_by_continent = nil
    end

    begin
      @regions = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.continental_and_regional_totals_and_data_quality where "CONTINENT"=?;
      SQL
    rescue
      @regions = nil
    end

    begin
      @regions_sum = execute <<-SQL, @continent
        SELECT *
        FROM #{db}.continental_and_regional_totals_and_data_quality_sum where "CONTINENT"=?;
      SQL
    rescue
      @regions_sum = nil
    end

  end

  def region
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    db = "aed#{@year}"

    begin
      @summary_totals_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.summary_totals_by_region where "REGION"=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      @summary_sums_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.summary_sums_by_region where "REGION"=?
      SQL
    rescue
      @summary_sums_by_region = nil
    end

    begin
      @causes_of_change_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.causes_of_change_by_region where "REGION"=?
      SQL
    rescue
      @causes_of_change_by_region = nil
    end

    begin
      @causes_of_change_sums_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.causes_of_change_sums_by_region where "REGION"=?
      SQL
    rescue
      @causes_of_change_sums_by_region = nil
    end

    begin
      @area_of_range_covered_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.area_of_range_covered_by_region where "REGION"=?
      SQL

      @area_of_range_covered_sum_by_region = execute <<-SQL, @region
        SELECT *
        FROM #{db}.area_of_range_covered_sum_by_region where "REGION"=?
      SQL
    rescue
      @area_of_range_covered_by_region = nil
      @area_of_range_covered_sum_by_region = nil
    end

    begin
      @countries = execute <<-SQL, @region
        SELECT *
        FROM #{db}.country_and_regional_totals_and_data_quality where "REGION"=?;
      SQL
    rescue
      @countries = nil
    end

    begin
      @countries_sum = execute <<-SQL, @region
        SELECT *
        FROM #{db}.country_and_regional_totals_and_data_quality_sum where "REGION"=?;
      SQL
    rescue
      @countries_sum = nil
    end
  end

  def country
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
    db = "aed#{@year}"

    conn = ActiveRecord::Base.connection.instance_variable_get("@connection")

    begin
      ccodes = execute <<-SQL, @country
        SELECT "CCODE"
        FROM #{db}."Country" where "CNTRYNAME"=?
      SQL
      @ccode = ccodes[0]['CCODE']
    rescue => e
      @ccode = @country
    end

    begin
      @causes_of_change_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.causes_of_change_by_country where ccode=?
      SQL
    rescue
      @causes_of_change_by_country = nil
    end

    begin
      @causes_of_change_sums_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.causes_of_change_sums_by_country where ccode=?
      SQL
    rescue
      @causes_of_change_sums_by_country = nil
    end

    begin
      @summary_totals_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.summary_totals_by_country where ccode=?
      SQL
    rescue
      raise ActiveRecord::RecordNotFound
    end

    begin
      @summary_sums_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.summary_sums_by_country where ccode=?
      SQL
    rescue
      @summary_sums_by_country = nil
    end

    begin
      @area_of_range_covered_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.area_of_range_covered_by_country where ccode=?
      SQL

      @area_of_range_covered_sum_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.area_of_range_covered_sum_by_country where ccode=?
      SQL
    rescue
      @area_of_range_covered_by_country = nil
      @area_of_range_covered_sum_by_country = nil
    end

    begin
      @elephant_estimates_by_country = execute <<-SQL, @ccode
        SELECT *
        FROM #{db}.elephant_estimates_by_country where ccode=?
      SQL
    rescue
      @elephant_estimates_by_country = nil
    end

  end

  def survey
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
    @survey = params[:survey]
    db = "aed#{@year}"
    if @survey.to_i > 0
      survey_zones = execute <<-SQL, @survey
        SELECT *
        FROM #{db}.elephant_estimates_by_country where "OBJECTID"=?
      SQL
      survey_zones.each do |survey_zone|
        @survey_zone = survey_zone
        break
      end
    end
    if @survey_zone.nil?
      raise ActiveRecord::RecordNotFound
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
