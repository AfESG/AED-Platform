module AltDppsHelper

  @@blank_cells = nil

  def unused_cell
    content_tag :td, '&mdash;'.html_safe, class: 'text-center'
  end

  def rounded number
    case number
    when 0..4 then number.round
    when 5..1000 then number.round(-1)
    else number.round(-2)
    end
  end

  def round_area area
    area.to_f.round(1)
  end

  def round_area_cell area, opts={}
    defaults = { class: 'numeric' }
    defaults.merge!(opts[:attrs]) if opts[:attrs]
    content_tag :td, round_area(area), defaults
  end

  def round_area_sqkm_cell area
    content_tag :td, number_with_delimiter(area.to_f.round), class: 'numeric'
  end

  def numeric_cell value, opts={}
    defaults = { class: 'numeric' }
    defaults.merge!(opts[:attrs]) if opts[:attrs]
    content_tag :td, number_with_delimiter(value.to_f.round(opts[:precision] || 0)), defaults
  end

  def is_blank_cell? row, column
    return false unless row['CATEGORY']

    @@blank_cells ||= {
      'A': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX'],
      'B': ['GUESS_MIN', 'GUESS_MAX'],
      'C': ['CONFIDENCE'],
      'D': ['CONFIDENCE'],
      'E': ['CONFIDENCE'],
      'F': ['ESTIMATE', 'CONFIDENCE'],
      'G': ['ESTIMATE', 'CONFIDENCE']
    }

    values = @@blank_cells[row['CATEGORY'].to_sym]
    return !values.nil? && values.include?(column)
  end

  def add_and_display_area_cell row, column, totals, opts={}
    begin
      totals[column] ||= 0
      value = row[column] || 0
      if value.nil?
        unused_cell
      else
        num = value.to_f
        totals[column] += num
        round_area_cell num, opts
      end
    rescue
      '!ERR!'
    end
  end

  def add_and_display_cell row, column, totals, opts={}
    totals[column] ||= 0
    round = opts[:round] || false
    value = row[column]
    if value.nil? || is_blank_cell?(row, column)
      unused_cell
    else
      num = value.to_f.round(opts[:precision] || 0)
      totals[column] += num
      defaults = { class: 'numeric' }
      defaults.merge!(opts[:attrs]) if opts[:attrs]
      content_tag :td, number_with_delimiter(round ? rounded(num) : num), defaults
    end
  end

  def alt_dpps_country_area scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        a.category,
        a."AREA",
        a."AREA" / ct."RANGE_AREA" * 100 as "CATEGORY_RANGE_ASSESSED",
        ct."RANGE_AREA" as range_area,
        ct."CATEGORY_PERCENT_RANGE_ASSESSED" as percent_range_assessed
      FROM (
        SELECT
          category, region, country, sum(area_sqkm) as "AREA"
        FROM
          survey_range_intersection_metrics_add sm
        WHERE
          analysis_year = #{@year}
          #{analysis_name}
          AND #{scope}
        GROUP BY category, region, country
      ) a
      JOIN country_range_totals ct ON ct.country = a.country AND analysis_year = #{@year}
      ORDER BY category
    SQL
  end

  def alt_dpps_region_area scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        a.category,
        a."AREA",
        a."AREA" / rt.range_area * 100 as "CATEGORY_RANGE_ASSESSED",
        rt.range_area,
        rt.percent_range_assessed
      FROM (
        SELECT
          category, region, sum(area_sqkm) as "AREA"
        FROM
          survey_range_intersection_metrics_add sm
        WHERE
          analysis_year = #{@year}
          #{analysis_name}
          AND #{scope}
        GROUP BY category, region
      ) a
      JOIN regional_range_totals rt ON rt.region = a.region
      ORDER BY category
    SQL
  end

  def alt_dpps_continent_area scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        a.category,
        a."AREA",
        a."AREA" / rt.range_area * 100 as "CATEGORY_RANGE_ASSESSED",
        rt.range_area,
        rt.percent_range_assessed
      FROM (
        SELECT
          category, sum(area_sqkm) as "AREA"
        FROM
          survey_range_intersection_metrics_add sm
        WHERE
          analysis_year = #{@year}
          #{analysis_name}
          AND #{scope}
        GROUP BY category
      ) a
      JOIN continental_range_totals rt ON rt.continent = 'Africa'
      ORDER BY category
    SQL
  end

  def alt_dpps_region_stats scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX",
        "ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX") as "PF",
        "ASSESSED_RANGE" / "RANGE_AREA" as "ARF",
        ("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA") AS "IQI",
        ("RANGE_AREA" / cont.range_area) AS "CRF",
        log((1+("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA")) / ("RANGE_AREA" / cont.range_area)) AS "PFS",
        "RANGE_AREA",
        "RANGE_AREA" / rrt.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        "ASSESSED_RANGE" / "RANGE_AREA" * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM (
        SELECT
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) as "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          sum(distinct "ASSESSED_RANGE") AS "ASSESSED_RANGE",
          sum(distinct "RANGE_AREA") AS "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year
        WHERE
          x.analysis_year = 2013
          AND x.analysis_name = '2013_africa_final'
        GROUP BY x.region
      ) p
      JOIN regional_range_totals rrt ON rrt.region = p.region
      JOIN continental_range_totals cont ON continent = 'Africa'
      WHERE
        p.#{scope}
      ORDER BY p.region
    SQL
  end

  def alt_dpps_country_stats scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        p.country,
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX",
        "ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX") as "PF",
        "ASSESSED_RANGE" / "RANGE_AREA" as "ARF",
        ("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA") AS "IQI",
        ("RANGE_AREA" / cont.range_area) AS "CRF",
        log((1+("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA")) / ("RANGE_AREA" / cont.range_area)) AS "PFS",
        "ASSESSED_RANGE",
        "RANGE_AREA",
        "RANGE_AREA" / rrt.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        "ASSESSED_RANGE" / "RANGE_AREA" * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM (
        SELECT
          x.country,
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) as "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          "ASSESSED_RANGE",
          "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.country, x.region, "RANGE_AREA", "ASSESSED_RANGE"
      ) p
      JOIN regional_range_totals rrt ON rrt.region = p.region
      JOIN continental_range_totals cont ON continent = 'Africa'
      WHERE
        p.#{scope}
      ORDER BY country
    SQL
  end

  def alt_dpps_continental_stats scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        p.region,
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX",
        "ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX") as "PF",
        "ASSESSED_RANGE" / "RANGE_AREA" as "ARF",
        ("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA") AS "IQI",
        ("RANGE_AREA" / cont.range_area) AS "CRF",
        log((1+("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA")) / ("RANGE_AREA" / cont.range_area)) AS "PFS",
        "ASSESSED_RANGE",
        "RANGE_AREA",
        "RANGE_AREA" / cont.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        "ASSESSED_RANGE" / "RANGE_AREA" * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM (
        SELECT
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) AS "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          range_assessed as "ASSESSED_RANGE",
          range_area as "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN regional_range_totals rt ON rt.region = x.region
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.region, "RANGE_AREA", "ASSESSED_RANGE"
      ) p
      JOIN continental_range_totals cont ON continent = 'Africa'
      ORDER BY region
    SQL
  end

  def alt_dpps_continental_stats_sums scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX",
        "ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX") as "PF",
        "ASSESSED_RANGE" / "RANGE_AREA" as "ARF",
        ("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA") AS "IQI",
        ("RANGE_AREA" / cont.range_area) AS "CRF",
        log((1+("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * ("ASSESSED_RANGE" / "RANGE_AREA")) / ("RANGE_AREA" / cont.range_area)) AS "PFS",
        "ASSESSED_RANGE",
        "RANGE_AREA",
        "RANGE_AREA" / cont.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        "ASSESSED_RANGE" / "RANGE_AREA" * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM (
        SELECT
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) AS "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          sum(distinct range_assessed) as "ASSESSED_RANGE",
          sum(distinct range_area) as "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN regional_range_totals rt ON rt.region = x.region
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
      ) p
      JOIN continental_range_totals cont ON continent = 'Africa'
    SQL
  end

  def alt_dpps scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND s.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
      "CATEGORY",
      "SURVEYTYPE",
      sum("ESTIMATE") AS "ESTIMATE",
      1.96*sqrt(sum("POPULATION_VARIANCE")) AS "CONFIDENCE",
      sum("GUESS_MIN") AS "GUESS_MIN",
      sum("GUESS_MAX") AS "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_totals_for_add s
      WHERE
        s.analysis_year = #{year}
        #{analysis_name}
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"
      ORDER BY "CATEGORY"
    SQL
  end

  def old_alt_dpps scope, year
    <<-SQL
      SELECT
        CASE
          WHEN e.completion_year > #{year - 10} THEN e.category
          ELSE 'F'
        END "CATEGORY",
        CASE
          WHEN e.completion_year > #{year - 10} THEN surveytype
          ELSE 'Degraded Data'
        END "SURVEYTYPE",
        sum(e.actually_seen) as seen,
        sum(e.population_estimate) as estimate,
        sum(e.population_lower_confidence_limit) as min,
        sum(e.population_upper_confidence_limit) as max,
        1.96*sqrt(sum(e.population_variance)) as confidence,
        sum(e.population_variance) as var,
        sum(e.stratum_area) as area
      FROM
        estimate_factors_analyses_categorized e
      JOIN population_submissions ps ON ps.id = e.population_submission_id
      JOIN submissions s ON ps.submission_id = s.id
      JOIN countries c ON s.country_id = c.id
      JOIN regions r ON c.region_id = r.id
      JOIN surveytypes st ON e.category = st.category
      WHERE
        e.analysis_year = #{year}
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"
      ORDER BY "CATEGORY"
    SQL
  end

end
