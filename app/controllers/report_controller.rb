class ReportController < ApplicationController
  include AltDppsHelper
  include DppsContinentHelper
  include DppsRegionHelper
  include DppsCountryHelper
  include TotalizerHelper
  include DppsContinentPreviousHelper
  include DppsRegionPreviousHelper
  include DppsCountryPreviousHelper

  before_filter :all_publication_years, :set_analysis

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

  #
  # Sets the Analysis unless it's a legacy request.
  #
  def set_analysis
    year = params.include?(:year) ? params[:year].to_i : nil

    if legacy_request?
      @analysis = nil
      @title = nil
      @analysis_year = year
      @publication_year = year
    else
      @analysis = Analysis.find_by(publication_year: year) if year.present?
      @title = @analysis&.title
      @analysis_year = @analysis&.analysis_year
      @publication_year = @analysis&.publication_year
    end
  end

  #
  # Gets all the Years including legacy years.
  #
  def all_publication_years
    @all_publication_years ||= AedUtils.all_publication_years
  end

  def species
    @reports = (current_user&.admin? ? Analysis.all : Analysis.published).order(publication_year: :desc)
    @legacy_reports = AedLegacy.reports
  end

  def year
    # Uses @publication_year from #set_analysis
  end

  def corrections
    if legacy_request?
      return nil
    end

    @continent = params[:continent]
  end

  def continent
    @continent = params[:continent]

    if legacy_request?
      get_continent_previous_values(@continent, @analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end

      render 'report/legacy_continent'
    else
      @analysis_year = @analysis.analysis_year
      @comp_year = @analysis.comparison_year

      # ADD values
      if params[:forest_only]
        scope = "phenotype NOT IN ('Savanna', 'Savanna with hybrid')"
        alt_scope = "\"CLASSIFICATION\" != 'Savanna'"
      else
        scope = "1=1"
        alt_scope = "1=1"
      end
      @alt_summary_totals = execute alt_dpps(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums = execute alt_dpps_totals(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums_s = execute alt_dpps_totals(scope, @comp_year, @analysis.analysis_name) if @comp_year != @analysis.analysis_year
      @alt_areas = execute alt_dpps_continent_area("1=1", @analysis.analysis_year, @analysis.analysis_name)
      @alt_regions = execute alt_dpps_continental_stats(alt_scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_regions_sums = execute alt_dpps_continental_stats_sums(alt_scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change = execute alt_dpps_causes_of_change("1=1", @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("1=1", @analysis.analysis_year, @analysis.analysis_name)
      @alt_areas_by_reason = execute alt_dpps_continent_area_by_reason("1=1", @analysis.analysis_year, @analysis.analysis_name)

      # DPPS values
      get_continent_values(@continent, @analysis.analysis_name, @analysis.analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end
      @summary_totals_by_continent = execute totalizer("1=1", @analysis.analysis_name, @analysis.analysis_year)
      if @summary_totals_by_continent.num_tuples < 1
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end

  def region
    @continent = params[:continent]

    if legacy_request?
      @region = params[:region].gsub('_', ' ')
      get_region_previous_values(@region, @analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end

      render 'report/legacy_region'
    else
      @comp_year = @analysis.comparison_year
      @region = params[:region].gsub('_', ' ')

      # ADD values
      scope = "region = '#{@region}'"
      scope += " AND phenotype NOT IN ('Savanna', 'Savanna with hybrid')" if params[:forest_only]
      @alt_summary_totals = execute alt_dpps(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums = execute alt_dpps_totals(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums_s = execute alt_dpps_totals(scope, @comp_year, @analysis.analysis_name) if @comp_year != @analysis.analysis_year
      @alt_areas = execute alt_dpps_region_area("region = '#{@region}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_countries = execute alt_dpps_region_stats(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_country_sums = execute alt_dpps_region_stats_sums(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change = execute alt_dpps_causes_of_change("region = '#{@region}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("region = '#{@region}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_areas_by_reason = execute alt_dpps_region_area_by_reason("region = '#{@region}'", @analysis.analysis_year, @analysis.analysis_name)

      # DPPS values
      get_region_values(@region, @analysis.analysis_name, @analysis.analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end
      @summary_totals_by_region = execute totalizer("region='#{@region}'", @analysis.analysis_name, @analysis.analysis_year)
      if @summary_totals_by_region.num_tuples < 1
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end

  def country
    @continent = params[:continent]
    @region = params[:region].gsub('_', ' ')
    @country = params[:country].gsub('_', ' ')

    if legacy_request?
      get_country_previous_values(@country, @analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end

      render 'report/legacy_country'
    else
      @comp_year = @analysis.comparison_year
      @map_uri = Country.where(name: @country).first().iso_code + "/" + @analysis.analysis_name + "/" + params[:year]

      # ADD values
      if params[:forest_only]
        scope = "country = '#{sql_escape @country}' AND phenotype NOT IN ('Savanna', 'Savanna with hybrid')"
        alt_scope = "phenotype NOT IN ('Savanna', 'Savanna with hybrid')"
      else
        scope = "country = '#{sql_escape @country}'"
        alt_scope = "1=1"
      end
      @alt_summary_totals = execute alt_dpps(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums = execute alt_dpps_totals(scope, @analysis.analysis_year, @analysis.analysis_name)
      @alt_summary_sums_s = execute alt_dpps_totals(scope, @comp_year, @analysis.analysis_name) if @comp_year != @analysis.analysis_year
      @alt_areas = execute alt_dpps_country_area("country = '#{sql_escape @country}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change = execute alt_dpps_causes_of_change("country = '#{sql_escape @country}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_causes_of_change_s = execute alt_dpps_causes_of_change_sums("country = '#{sql_escape @country}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_areas_by_reason = execute alt_dpps_country_area_by_reason("country = '#{sql_escape @country}'", @analysis.analysis_year, @analysis.analysis_name)
      @alt_elephant_estimates_by_country = execute alt_dpps_country_stats(@country, @analysis.analysis_year, @analysis.analysis_name, alt_scope)

      @alt_elephant_estimate_groups = []
      group = []
      current_replacement_name = @alt_elephant_estimates_by_country[0]['replacement_name']
      @alt_elephant_estimates_by_country.each do |row|
        if row['replacement_name'] == current_replacement_name
          group << row
        else
          @alt_elephant_estimate_groups << group
          group = []
          group << row
          current_replacement_name = row['replacement_name']
        end
      end
      @alt_elephant_estimate_groups << group

      # DPPS values
      get_country_values(@country, @analysis.analysis_name, @analysis.analysis_year).each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end
      @summary_totals_by_country = execute totalizer("country='#{sql_escape @country}'", @analysis.analysis_name, @analysis.analysis_year)
      if @summary_totals_by_country.num_tuples < 1
        raise ActionController::RoutingError.new('Not Found')
      end

      @ioc_tabs = [
          {
              title: 'ADD',
              template: 'table_causes_of_change_add',
              args: {
                  totals: @alt_causes_of_change,
                  sums: @alt_causes_of_change_s
              }
          },
          {
              title: 'DPPS',
              template: 'table_causes_of_change_dpps',
              args: {
                  base_totals: @causes_of_change_by_country_u,
                  base_sums: @causes_of_change_sums_by_country_u,
                  scaled_totals: @causes_of_change_by_country,
                  scaled_sums: @causes_of_change_sums_by_country
              }
          }
      ]
    end
  end

  def site
    if legacy_request?
      return nil
    end

    @continent = params[:continent]
    @site = params[:site].gsub('_', ' ')

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
        where e.analysis_name = '#{@analysis.analysis_name}' and e.analysis_year = '#{@analysis.analysis_year}'
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
        where e.analysis_name = '#{@analysis.analysis_name}' and e.analysis_year = '#{@analysis.analysis_year}'
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
        where e.analysis_name = '#{@analysis.analysis_name}' and e.analysis_year = '#{@analysis.analysis_year}'
        and replacement_name=?
      order by e.site_name, e.stratum_name
    SQL

    @causes_of_change_by_site = execute <<-SQL, @site
      SELECT *
      FROM causes_of_change_by_site where site=?
        and analysis_name = '#{@analysis.analysis_name}' and analysis_year = '#{@analysis.analysis_year}'
    SQL

    @causes_of_change_sums_by_site = execute <<-SQL, @site
      SELECT *
      FROM causes_of_change_sums_by_site where site=?
        and analysis_name = '#{@analysis.analysis_name}' and analysis_year = '#{@analysis.analysis_year}'
    SQL
  end

  def survey
    @continent = params[:continent]
    @region = params[:region].gsub('_', ' ')
    @country = params[:country].gsub('_', ' ')
    @survey = params[:survey]
    db = "aed#{@analysis_year}"
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
    @bibliography = execute <<-SQL, @analysis.analysis_name
      select input_zone_id, short_citation, citation from estimate_factors join new_strata on analysis_name=? and input_zone_id=new_stratum;
    SQL
  end

  def appendix_1
    @table = execute <<-SQL, @analysis.analysis_name, @analysis.analysis_name
      SELECT
        x.country "Country",
	substring(c.region from 1 for 1) "Region",
        TO_CHAR(x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX"),'990D99') as "Probable Fraction",
        TO_CHAR(crt."ASSESSED_RANGE" / crt."RANGE_AREA",'990D99') as "Assessed Range Fraction",
        TO_CHAR((x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA"),'990D99') AS "IQI",
	TO_CHAR(((x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA"))-prev_iqi,'990D99') "Change on Previous Report",
        TO_CHAR((crt."RANGE_AREA" / cont.range_area)*100,'990D99%') "Continental Range Fraction",
        ROUND(log((1+(x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA")) / (crt."RANGE_AREA" / cont.range_area))) "PFS"
      FROM estimate_factors_analyses_categorized_totals_country_for_add x
      JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year AND crt.analysis_name = x.analysis_name
      JOIN regional_range_totals rrt ON rrt.region = crt.region AND rrt.analysis_name = crt.analysis_name AND rrt.analysis_year = crt.analysis_year
      JOIN continental_range_totals cont ON cont.continent = 'Africa' AND cont.analysis_name = rrt.analysis_name AND cont.analysis_year = rrt.analysis_year
      JOIN analyses a ON x.analysis_year = a.analysis_year
      JOIN country c ON c.cntryname = x.country
      JOIN
      ( SELECT
          x.country,
          (x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA") AS prev_iqi
        FROM
        analyses a
        JOIN estimate_factors_analyses_categorized_totals_country_for_add x
	       ON x.analysis_year = a.comparison_year
	       AND x.analysis_name = a.analysis_name
        JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = a.comparison_year AND crt.analysis_name = x.analysis_name
        JOIN regional_range_totals rrt ON rrt.region = crt.region AND rrt.analysis_name = a.analysis_name AND rrt.analysis_year = a.comparison_year
        JOIN continental_range_totals cont ON cont.continent = 'Africa' AND cont.analysis_name = a.analysis_name AND cont.analysis_year = a.comparison_year
        JOIN country c ON c.cntryname = x.country
        WHERE
  	     a.analysis_name = ?
      ) prev ON prev.country = x.country
      WHERE
	     a.analysis_name = ?
      ORDER BY "PFS", "Country";
    SQL
  end

  def appendix_2
    @table = execute <<-SQL, @analysis.analysis_name
      SELECT
        analysis_year,
        region,
        country,
        replacement_name,
        estimate_type,
        estimate,
        confidence
      FROM appendix_2_add
      WHERE analysis_name = ?
    SQL
    @regional_totals = execute <<-SQL, @analysis.analysis_name, @analysis.analysis_name
      SELECT
        analysis_year,
        region,
        sum(population_estimate) AS estimate,
        1.96*sqrt(sum(population_variance)) AS confidence
      FROM ioc_add_new_base
      WHERE
        reason_change = 'RS' AND analysis_name = ?
      GROUP BY analysis_year, region
      UNION
      SELECT
        analysis_year,
        region,
        sum(population_estimate) AS estimate,
        1.96*sqrt(sum(population_variance)) AS confidence
      FROM ioc_add_replaced_base
      WHERE
        reason_change = 'RS' AND analysis_name = ?
      GROUP BY analysis_year, region
      ORDER BY region, analysis_year
    SQL
  end

  def general_statistics
    @table = execute <<-SQL, @analysis.analysis_name
      select
        crt.region,
        pam.country,
        pam.stated country_area,
        ROUND("RANGE_AREA") range_area,
        ROUND(("RANGE_AREA"/pam.stated)*100) percent_range_area,
        percent_protected protected_area_coverage,
        cprm.percent_protected_range protected_range,
        to_char((x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA"),'990D99') iqi
      from country_pa_metrics pam
      join country_range_totals crt
      on pam.country = crt.country
      join country_pa_range_metrics cprm
      on crt.country = cprm.country
      join analyses a
      on crt.analysis_name = a.analysis_name
      and crt.analysis_year = a.analysis_year
      join estimate_factors_analyses_categorized_totals_country_for_add x
      on x.analysis_name = a.analysis_name
      and x.analysis_year = a.analysis_year
      and crt.country = x.country
      where crt.analysis_name = ?
      order by region, pam.country;
    SQL

    @regional_table = execute <<-SQL, @analysis.analysis_name, @analysis.analysis_name
      select
        s1.region,
        s1.country_area region_area,
        s1.range_area,
        s1.percent_range_area,
        TO_CHAR((s3.pa_area / s1.country_area)*100,'990D99') protected_area_coverage,
        s4.percent_protected protected_range,
        s2.iqi
        from
      (
            select
              crt.region,
              sum(pam.stated) country_area,
              ROUND(sum("RANGE_AREA")) range_area,
              ROUND((sum("RANGE_AREA")/sum(pam.stated))*100) percent_range_area
            from country_pa_metrics pam
            join country_range_totals crt
            on pam.country = crt.country
            join analyses a
            on crt.analysis_name = a.analysis_name
            and crt.analysis_year = a.analysis_year
            where crt.analysis_name = ?
            group by region
      ) s1
        join
      (
            select
              crt.region,
              to_char((x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt.range_assessed / crt.range_area),'990D99') iqi
            from regional_range_totals crt
            join analyses a
            on crt.analysis_name = a.analysis_name
            and crt.analysis_year = a.analysis_year
            join estimate_factors_analyses_categorized_totals_region_for_add x
            on x.analysis_name = a.analysis_name
            and x.analysis_year = a.analysis_year
            and crt.region = x.region
            where crt.analysis_name = ?
      ) s2
      on s1.region = s2.region
        join
      (
            select
              region,
              sum(protected_area_sqkm) pa_area
            from country
            join country_pa_metrics
            on cntryname=country
            group by region
      ) s3
      on s1.region = s3.region
        join
      (
            select
      	region,
              TO_CHAR((sum(protected_area_range_sqkm)/sum(range_sqkm))*100,'990D99') percent_protected
      	from country
      	join country_pa_range_metrics
      	on cntryname=country group by region
      ) s4
      on s1.region = s4.region
      order by region;
    SQL

    @continental_table = execute <<-SQL, @analysis.analysis_name, @analysis.analysis_name
      select
      s1.country_area continental_area,
      s1.range_area,
      s1.percent_range_area,
      TO_CHAR((s3.pa_area / s1.country_area)*100,'990D99') protected_area_coverage,
      s4.percent_protected protected_range,
      s2.iqi
      from
    (
          select
            sum(pam.stated) country_area,
            ROUND(sum("RANGE_AREA")) range_area,
            ROUND((sum("RANGE_AREA")/sum(pam.stated))*100) percent_range_area
          from country_pa_metrics pam
          join country_range_totals crt
          on pam.country = crt.country
          join analyses a
          on crt.analysis_name = a.analysis_name
          and crt.analysis_year = a.analysis_year
          where crt.analysis_name = ?
    ) s1,
    (
          select
            to_char((x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt.range_assessed / crt.range_area),'990D99') iqi
          from continental_range_totals crt
          join analyses a
          on crt.analysis_name = a.analysis_name
          and crt.analysis_year = a.analysis_year
          join estimate_factors_analyses_categorized_totals_continent_for_add x
          on x.analysis_name = a.analysis_name
          and x.analysis_year = a.analysis_year
          where crt.analysis_name = ?
    ) s2,
    (
          select
            sum(protected_area_sqkm) pa_area
          from country
          join country_pa_metrics
          on cntryname=country
    ) s3,
    (
          select
            TO_CHAR((sum(protected_area_range_sqkm)/sum(range_sqkm))*100,'990D99') percent_protected
    	from country
    	join country_pa_range_metrics
    	on cntryname=country
    ) s4
    SQL
  end

end
