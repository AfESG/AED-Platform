class ReportController < ApplicationController
  include AltDppsHelper
  include DppsContinentHelper
  include DppsRegionHelper
  include DppsCountryHelper
  include TotalizerHelper

  before_filter :set_past_years

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

  def set_past_years
    @past_years = ['2007', '2002', '1998', '1995']
  end

  def species
    @past_reports = [
      { year: '2007', full_text: '033', authors: 'J.J. Blanc, R.F.W. Barnes, G.C. Craig, H.T. Dublin, C.R. Thouless, I. Douglas-Hamilton, and J.A. Hart', errata: true },
      { year: '2002', full_text: '029', authors: 'J.J. Blanc, C.R. Thouless, J.A. Hart, H.T. Dublin, I. Douglas-Hamilton, G.C. Craig and R.F.W. Barnes', errata: true },
      { year: '1998', full_text: '022', authors: 'R.F.W. Barnes, G.C. Craig, H.T. Dublin, G. Overton, W. Simons and C.R. Thouless', errata: false },
      { year: '1995', full_text: '011', authors: 'M.Y. Said, R.N. Chunge, G.C. Craig, C.R. Thouless, R.F.W. Barnes and H.T. Dublin', errata: true }
    ]
  end

  def year
    @year = params[:year]
  end

  before_filter :maybe_authenticate_user!, :only => [:preview_continent, :preview_region, :preview_country]

  # define official titles for certain filters
  def official_title(filter)
    if filter == "2013_africa_final"
      return "Provisional African Elephant Population Estimates: update to 31 Dec 2013"
    end
    return nil
  end

  def preview_corrections
    return unless allowed_preview?
    @year = params[:year].to_i
    @continent = params[:continent]
    @filter = params[:filter]
    @preview_title = official_title(@filter) or @filter.humanize.upcase
  end

  def preview_continent
    return unless allowed_preview?
    @year = params[:year].to_i
    @continent = params[:continent]
    @filter = params[:filter]
    @preview_title = official_title(@filter) or @filter.humanize.upcase

    # ADD values
    @alt_summary_totals = execute alt_dpps("1=1", @year, @filter)
    @alt_summary_sums   = execute alt_dpps_totals("1=1", @year, @filter)
    @alt_areas          = execute alt_dpps_continent_area("1=1", @year, @filter)
    @alt_regions        = execute alt_dpps_continental_stats("1=1", @year, @filter)
    @alt_regions_sums   = execute alt_dpps_continental_stats_sums("1=1", @year, @filter)
    @alt_causes_of_change = execute alt_dpps_causes_of_change("1=1", @year, @filter)
    @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("1=1", @year, @filter)
    @alt_areas_by_reason  = execute alt_dpps_continent_area_by_reason("1=1", @year, @filter)

    # DPPS values
    get_continent_values(@continent, @filter, @year).each do |k, v|
      instance_variable_set("@#{k}".to_sym, v)
    end
    @summary_totals_by_continent = execute totalizer("1=1",@filter,@year)
    if @summary_totals_by_continent.num_tuples < 1
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def continent
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
    return unless allowed_preview?
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @filter = params[:filter]
    @preview_title = official_title(@filter) or @filter.humanize.upcase

    # ADD values
    @alt_summary_totals = execute alt_dpps("region = '#{@region}'", @year, @filter)
    @alt_summary_sums   = execute alt_dpps_totals("region = '#{@region}'", @year, @filter)
    @alt_areas          = execute alt_dpps_region_area("region = '#{@region}'", @year, @filter)
    @alt_countries      = execute alt_dpps_country_stats("region = '#{@region}'", @year, @filter)
    @alt_country_sums   = execute alt_dpps_region_stats("region = '#{@region}'", @year, @filter)
    @alt_causes_of_change = execute alt_dpps_causes_of_change("region = '#{@region}'", @year, @filter)
    @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("region = '#{@region}'", @year, @filter)
    @alt_areas_by_reason  = execute alt_dpps_region_area_by_reason("region = '#{@region}'", @year, @filter)

    # DPPS values
    get_region_values(@region, @filter, @year).each do |k, v|
      instance_variable_set("@#{k}".to_sym, v)
    end
    @summary_totals_by_region = execute totalizer("region='#{@region}'",@filter,@year)
    if @summary_totals_by_region.num_tuples < 1
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def region
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
    return unless allowed_preview?
    @year = params[:year].to_i
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
    @map_uri = Country.where(name: @country).first().iso_code + "/" + params[:filter] + "/" + params[:year]
    @filter = params[:filter]
    @preview_title = official_title(@filter) or @filter.humanize.upcase

    # ADD values
    @alt_summary_totals = execute alt_dpps("country = '#{sql_escape @country}'", @year, @filter)
    @alt_summary_sums   = execute alt_dpps_totals("country = '#{sql_escape @country}'", @year, @filter)
    @alt_areas          = execute alt_dpps_country_area("country = '#{sql_escape @country}'", @year, @filter)
    @alt_causes_of_change = execute alt_dpps_causes_of_change("country = '#{sql_escape @country}'", @year, @filter)
    @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("country = '#{sql_escape @country}'", @year, @filter)
    @alt_areas_by_reason  = execute alt_dpps_country_area_by_reason("country = '#{sql_escape @country}'", @year, @filter)

    # DPPS values
    get_country_values(@country, @filter, @year).each do |k, v|
      instance_variable_set("@#{k}".to_sym, v)
    end
    @summary_totals_by_country = execute totalizer("country='#{sql_escape @country}'",@filter,@year)
    if @summary_totals_by_country.num_tuples < 1
      raise ActionController::RoutingError.new('Not Found')
    end

    @alt_elephant_estimates_by_country = execute <<-SQL, @country
      SELECT
        el.sort_key,
        el.population,
        e.site_name,
        e.stratum_name,
        e.replacement_name,
        e.population_variance,
        CASE WHEN e.reason_change = 'NC' THEN '-' ELSE e.reason_change END AS "ReasonForChange",
        e.population_submission_id,
        e.input_zone_id method_and_quality,
        e.category "CATEGORY",
        e.completion_year "CYEAR",
        e.best_estimate "ESTIMATE",
        e.population_lower_confidence_limit "GUESS_MIN",
        e.population_upper_confidence_limit "GUESS_MAX",
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
        e.short_citation "REFERENCE",
        round(log((1+(e.best_estimate / (e.best_estimate + (1.96*sqrt(e.population_variance)) + e.population_upper_confidence_limit + 0.0001))) / 
          (a.area_sqkm / rm.range_area))) "PFS",
        rm.range_area "RA",
        a.area_sqkm "CALC_SQKM",
        e.stratum_area "AREA_SQKM",
        CASE WHEN longitude<0 THEN
          to_char(abs(longitude),'999D9')||'W'
        WHEN longitude=0 THEN
          '0.0'
        ELSE
          to_char(abs(longitude),'999D9')||'E'
        END "LON",
        CASE WHEN latitude<0 THEN
          to_char(abs(latitude),'999D9')||'S'
        WHEN latitude=0 THEN
          '0.0'
        ELSE
          to_char(abs(latitude),'999D9')||'N'
        END "LAT"
      FROM estimate_locator el
        join estimate_factors_analyses_categorized_for_add e on e.input_zone_id = el.input_zone_id
          and e.analysis_name = el.analysis_name
          and e.analysis_year = el.analysis_year
        join estimate_locator_areas a on e.input_zone_id = a.input_zone_id
          and e.analysis_name = a.analysis_name
          and e.analysis_year = a.analysis_year
        join surveytypes t on t.category = e.category
        join population_submissions on e.population_submission_id = population_submissions.id
        join regional_range_table rm on e.country = rm.country AND 
          e.analysis_name = rm.analysis_name AND e.analysis_year = rm.analysis_year
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and e.country=?
      order by el.sort_key, e.site_name, e.stratum_name
    SQL

    @ioc_tabs = [
        {
            title: 'DPPS Interpretation of Changes',
            template: 'table_causes_of_change_dpps',
            args: {
                base_totals: @causes_of_change_by_country_u,
                base_sums: @causes_of_change_sums_by_country_u,
                scaled_totals: @causes_of_change_by_country,
                scaled_sums: @causes_of_change_sums_by_country
            }
        },
        {
            title: 'ADD Interpretation of Changes',
            template: 'table_causes_of_change_add',
            args: {
                totals: @alt_causes_of_change,
                sums: @alt_causes_of_change_s
            }
        }
    ]
  end

  def preview_site
    return unless allowed_preview?
    @year = params[:year].to_i
    @continent = params[:continent]
    @site = params[:site].gsub('_',' ')
    @filter = params[:filter]
    @preview_title = official_title(@filter) or @filter.humanize.upcase

    @summary_totals_by_site = execute <<-SQL, @site
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
        and replacement_name=?
      group by e.category, surveytype
      order by e.category;
    SQL
    @summary_sums_by_site = execute <<-SQL, @site
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
        and replacement_name=?
    SQL
    @elephant_estimates_by_site = execute <<-SQL, @site
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
        join surveytypes t on t.category = e.category
        join population_submissions on e.population_submission_id = population_submissions.id
        where e.analysis_name = '#{@filter}' and e.analysis_year = '#{@year}'
        and replacement_name=?
      order by e.site_name, e.stratum_name
    SQL

    @causes_of_change_by_site = execute <<-SQL, @site
      SELECT *
      FROM causes_of_change_by_site where site=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL

    @causes_of_change_sums_by_site = execute <<-SQL, @site
      SELECT *
      FROM causes_of_change_sums_by_site where site=?
        and analysis_name = '#{@filter}' and analysis_year = '#{@year}'
    SQL
  end

  def country
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

  def bibliography
    @filter = params[:filter]
    @bibliography = execute <<-SQL, @filter
      select input_zone_id, short_citation, citation from estimate_factors join new_strata on analysis_name=? and input_zone_id=new_stratum;
    SQL
  end

end
