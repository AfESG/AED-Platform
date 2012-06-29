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

  before_filter :authenticate_user!, :only => [:preview_continent, :preview_region, :preview_country]

  def preview_continent
    return unless current_user.admin?
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @filter = params[:filter]
    @preview_title = @filter.humanize.upcase

    @summary_totals_by_continent = execute <<-SQL
      select
        'Africa' "CONTINENT",
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
        from estimate_dpps e
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        group by e.category, surveytype
        order by e.category;
    SQL
    @summary_sums_by_continent = execute <<-SQL
      select
        'Africa' "CONTINENT",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
        from estimate_locator e
          join estimate_dpps d on e.input_zone_id = d.input_zone_id
            and e.analysis_name = d.analysis_name
            and e.analysis_year = d.analysis_year
          where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
    SQL
    begin
      @regions = nil
      @regions = execute <<-SQL, @continent
        select
          e.continent "CONTINENT",
          e.region "REGION",
          round(SUM(d.definite)) "DEFINITE",
          round(SUM(d.possible)) "POSSIBLE",
          round(SUM(d.probable)) "PROBABLE",
          round(SUM(d.speculative)) "SPECUL",
          0 "RANGEAREA",
          0 "RANGEPERC",
          0 "SURVRANGPERC",
          0 "INFQLTYIDX",
          0 "PFS"
        from
          estimate_locator e
          join estimate_dpps d on e.input_zone_id = d.input_zone_id
            and e.analysis_name = d.analysis_name
            and e.analysis_year = d.analysis_year
          where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        group by
          e.continent, e.region
        order by
          e.continent, e.region;
      SQL
      @regions_sum = execute <<-SQL, @continent
        select
          e.continent "CONTINENT",
          round(SUM(d.definite)) "DEFINITE",
          round(SUM(d.possible)) "POSSIBLE",
          round(SUM(d.probable)) "PROBABLE",
          round(SUM(d.speculative)) "SPECUL",
          0 "RANGEAREA",
          0 "RANGEPERC",
          0 "SURVRANGPERC",
          0 "INFQLTYIDX",
          0 "PFS"
        from
          estimate_locator e
          join estimate_dpps d on e.input_zone_id = d.input_zone_id
            and e.analysis_name = d.analysis_name
            and e.analysis_year = d.analysis_year
          where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        group by
          e.continent
        order by
          e.continent;
      SQL
    rescue
      @regions = nil
    end

    @causes_of_change_by_continent = execute <<-SQL, @continent
      SELECT *
      FROM causes_of_change_by_continent where continent=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL

    @causes_of_change_sums_by_continent = execute <<-SQL, @continent
      SELECT *
      FROM causes_of_change_sums_by_continent where continent=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
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

  def preview_region
    return unless current_user.admin?
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @filter = params[:filter]
    @preview_title = @filter.humanize.upcase

    @summary_totals_by_region = execute <<-SQL
      select
        region "REGION",
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and region='#{@region}'
      group by region, e.category, surveytype
      order by region, e.category;
    SQL
    @summary_sums_by_region = execute <<-SQL
      select
        region "REGION",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from
        estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and region='#{@region}'
      group by region
      order by region;
    SQL
    @countries = nil
    @countries = execute <<-SQL, @region
      select
        region "REGION",
        country "CNTRYNAME",
        round(SUM(d.definite)) "DEFINITE",
        round(SUM(d.possible)) "POSSIBLE",
        round(SUM(d.probable)) "PROBABLE",
        round(SUM(d.speculative)) "SPECUL",
        0 "RANGEAREA",
        0 "RANGEPERC",
        0 "SURVRANGPERC",
        0 "INFQLTYIDX",
        0 "PFS"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
          and region='#{@region}'
      group by region, country
      order by region, country
    SQL
    @countries_sum = execute <<-SQL, @continent
      select
        round(SUM(d.definite)) "DEFINITE",
        round(SUM(d.possible)) "POSSIBLE",
        round(SUM(d.probable)) "PROBABLE",
        round(SUM(d.speculative)) "SPECUL",
        0 "RANGEAREA",
        0 "RANGEPERC",
        0 "SURVRANGPERC",
        0 "INFQLTYIDX",
        0 "PFS"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
          and region='#{@region}'
      group by region
      order by region
    SQL
    @causes_of_change_by_region = execute <<-SQL, @region
      SELECT *
      FROM causes_of_change_by_region where region=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL
    @causes_of_change_sums_by_region = execute <<-SQL, @region
      SELECT *
      FROM causes_of_change_sums_by_region where region=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL
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

  def preview_country
    return unless current_user.admin?
    @species = params[:species].gsub('_',' ')
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
    @filter = params[:filter]
    @preview_title = @filter.humanize.upcase

    @summary_totals_by_country = execute <<-SQL, @country
      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and country=?
      group by e.category, surveytype
      order by e.category;
    SQL
    @summary_sums_by_country = execute <<-SQL, @country
      select
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and country=?
    SQL
    @elephant_estimates_by_country = execute <<-SQL, @country
      select
        CASE WHEN reason_change='NC' THEN
          '-'
        ELSE
          reason_change
        END as "ReasonForChange",
        e.population_submission_id,
        e.site_name || ' / ' || e.stratum_name survey_zone,
        e.input_zone_id method_and_quality,
        e.category "CATEGORY",
        e.completion_year "CYEAR",
        e.population_estimate "ESTIMATE",
        CASE WHEN e.population_confidence_interval is NULL THEN
          to_char(e.population_upper_confidence_limit,'9999999') || '*'
        ELSE
          to_char(ROUND(e.population_confidence_interval),'9999999')
        END "CL95",
        e.short_citation "REFERENCE",
        '-' "PFS",
        e.stratum_area "AREA_SQKM",
        CASE WHEN longitude<0 THEN
          to_char(abs(longitude),'999D9')||'W'
        WHEN longitude=0 THEN
          '0.0'
        ELSE
          to_char(abs(longitude),'999D9')||'E'
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
        join surveytypes t on t.category = e.category
        join population_submissions on e.population_submission_id = population_submissions.id
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and country=?
      order by e.site_name, e.stratum_name
    SQL

    @causes_of_change_by_country = execute <<-SQL, @country
      SELECT *
      FROM causes_of_change_by_country where country=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL

    @causes_of_change_sums_by_country = execute <<-SQL, @country
      SELECT *
      FROM causes_of_change_sums_by_country where country=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL
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
