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

  def round_pfs value
    v = value.to_i
    case
    when v < 1
      return 1
    when v > 5
      return 5
    else
      return value
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
    content_tag :td, number_with_delimiter((area).to_f.round), class: 'numeric'
  end

  def numeric_cell value, opts={}
    defaults = { class: 'numeric' }
    defaults.merge!(opts[:attrs]) if opts[:attrs]
    content_tag :td, number_with_delimiter(value.to_f.round(opts[:precision] || 0)), defaults
  end

  def signed_cell value, opts={}
    defaults = { class: 'numeric' }
    defaults.merge!(opts[:attrs]) if opts[:attrs]
    content_tag :td, signed_number(value.to_f.round(opts[:precision] || 0), opts), defaults
  end

  def error_cell message, opts={}
    defaults = { class: 'text-center', icon: 'exclamation-sign' }
    defaults.merge! opts
    content_tag :td, title: message, class: defaults[:class], 'data-message': message do
      content_tag :i, '', class: "glyphicon glyphicon-#{defaults[:icon]} text-danger"
    end
  end

  def is_blank_cell? row, column
    return false unless row['CATEGORY']

    @@blank_cells ||= {
      'A': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX'],
      'B': ['GUESS_MIN', 'GUESS_MAX'],
      'C': ['CONFIDENCE'],
      'D': ['CONFIDENCE'],
      'E': ['ESTIMATE', 'CONFIDENCE'],
      'F': ['ESTIMATE', 'CONFIDENCE'],
      'G': ['ESTIMATE', 'CONFIDENCE'],
      'H': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX'],
      'I': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX'],
      'J': ['GUESS_MIN', 'GUESS_MAX'],
      'K': ['GUESS_MIN', 'GUESS_MAX'],
      'L': ['GUESS_MIN', 'GUESS_MAX'],
      'M': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX'],
      'N': ['CONFIDENCE', 'GUESS_MIN', 'GUESS_MAX']
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
        num = round_pfs(num) if opts[:pfs]
        totals[column] += num
        round_area_cell num, opts
      end
    rescue StandardError => e
      error_cell e.message
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
  rescue StandardError => e
    error_cell e.message
  end

  def alt_dpps_causes_of_change scope, year, filter=nil
    alt_dpps_causes_of_change_query scope, year, filter: filter, group: true
  end

  def alt_dpps_causes_of_change_sums scope, year, filter=nil
    alt_dpps_causes_of_change_sums_query scope, year, filter:filter
  end

  def alt_dpps_causes_of_change_query scope, year, opts
    sql = { group_cols: '', group_by: '', analysis_name: '', order_by: '' }
    if opts[:group]
      sql[:group_cols] = 'cc.name AS "CAUSE", cc.display_order AS "SEQUENCE",'
      sql[:group_by] = 'GROUP BY cc.name, cc.display_order'
      sql[:order_by] = 'ORDER BY cc.display_order'
    end
    if opts[:filter]
      sql[:analysis_name] = "AND i.analysis_name = '#{opts[:filter]}'"
    end
    <<-SQL
      SELECT
        #{sql[:group_cols]}
        sum(estimate) as "ESTIMATE",
        1.96*sqrt(sum(population_variance)) as "CONFIDENCE",
        sum(guess_min) as "GUESS_MIN",
        sum(guess_max) as "GUESS_MAX"
      FROM add_sums_country_category_reason i
      JOIN cause_of_changes cc ON cc.code = i.reason_change
      WHERE
        (i.reason_change IS NOT NULL AND i.reason_change <> '-')
        AND i.analysis_year = #{year}
        #{sql[:analysis_name]}
        AND #{scope}
      #{sql[:group_by]}
      #{sql[:order_by]}
    SQL
  end

  def alt_dpps_causes_of_change_sums_query scope, year, opts
    sql = { analysis_name: '' }
    if opts[:filter]
      sql[:analysis_name] = "AND t.analysis_name = '#{opts[:filter]}'"
    end
    if scope.include? 'country'
      sql[:table] = 'country'
    elsif scope.include? 'region'
      sql[:table] = 'region'
    else
      sql[:table] = 'continent'
    end
    <<-SQL
      SELECT
        estimate as "ESTIMATE",
        confidence as "CONFIDENCE",
        guess_min as "GUESS_MIN",
        guess_max as "GUESS_MAX"
      FROM add_totals_#{sql[:table]}_category_reason t
      WHERE
        t.analysis_year = #{year}
        #{sql[:analysis_name]}
        AND #{scope}
    SQL
  end


  def old_alt_dpps_causes_of_change_query scope, year, opts
    sql = { group_cols: '', group_by: '', analysis_name: '', order_by: '' }
    if opts[:group]
      sql[:group_cols] = 'cc.name AS "CAUSE", cc.display_order AS "SEQUENCE",'
      sql[:group_by] = 'GROUP BY cc.name, cc.display_order'
      sql[:order_by] = 'ORDER BY cc.display_order'
    end
    if opts[:filter]
      sql[:analysis_name] = "AND a.analysis_name = '#{opts[:filter]}'"
    end
    <<-SQL
      SELECT
        #{sql[:group_cols]}
        sum(i.new_be - i.old_be) as "ESTIMATE",
        sum(i.new_pv - i.old_pv) as "CONFIDENCE",
        sum(i.new_lcl - i.old_lcl) as "GUESS_MIN",
        sum(i.new_ucl - i.old_ucl) as "GUESS_MAX"
      FROM (
        SELECT
          old.input_zone_id as i_replaced_stratum,
          CASE
            WHEN new.reason_change = '-' AND new.age > 10 THEN 'DD'
            ELSE new.reason_change
          END as i_reason_change,
          COALESCE(old.best_estimate, 0) as old_be,
          COALESCE(1.96*sqrt(old.population_variance), 0) as old_pv,
          COALESCE(old.population_lower_confidence_limit, 0) as old_lcl,
          COALESCE(old.population_upper_confidence_limit, 0) as old_ucl,
          sum(new.best_estimate) as new_be,
          sum(1.96*sqrt(new.population_variance)) as new_pv,
          sum(new.population_lower_confidence_limit) as new_lcl,
          sum(new.population_upper_confidence_limit) as new_ucl
        FROM analyses a
        JOIN changes ch ON ch.analysis_name = a.analysis_name
        LEFT JOIN estimate_factors_analyses_categorized_for_add new ON
          new.analysis_name = a.analysis_name AND new.analysis_year = a.analysis_year AND 
          new.input_zone_id = ANY((regexp_split_to_array(ch.new_strata::text, ','::text)))
        LEFT JOIN estimate_factors_analyses_categorized_for_add old ON 
          old.analysis_name = a.analysis_name AND old.analysis_year = a.comparison_year AND 
          old.input_zone_id = ANY((regexp_split_to_array(ch.replaced_strata::text, ','::text)))
        JOIN countries c ON new.country = c.name
        JOIN regions r ON c.region_id = r.id
        WHERE
          (ch.reason_change IS NOT NULL AND ch.reason_change <> '-')
          AND a.analysis_year = #{year}
          #{sql[:analysis_name]}
          AND #{scope}
        GROUP BY i_replaced_stratum, i_reason_change, old_be, old_pv, old_lcl, old_ucl
      ) i
      JOIN cause_of_changes cc ON cc.code = i.i_reason_change
      #{sql[:group_by]}
      #{sql[:order_by]}
    SQL
  end

  def alt_dpps_country_area_by_reason scope, year, filter=nil
    alt_dpps_area_query scope, year, 'country', filter: filter, category: 'reason_change'
  end

  def alt_dpps_region_area_by_reason scope, year, filter=nil
    alt_dpps_area_query scope, year, 'region', filter: filter, category: 'reason_change'
  end

  def alt_dpps_continent_area_by_reason scope, year, filter=nil
    alt_dpps_area_query scope, year, 'continent', filter: filter, category: 'reason_change'
  end

  def alt_dpps_country_area scope, year, filter=nil
    alt_dpps_area_query scope, year, 'country', filter: filter
  end

  def alt_dpps_region_area scope, year, filter=nil
    alt_dpps_area_query scope, year, 'region', filter: filter
  end

  def alt_dpps_continent_area scope, year, filter=nil
    alt_dpps_area_query scope, year, 'continent', filter: filter
  end

  def alt_dpps_area_query scope, year, level, opts={}
    analysis_name = opts[:filter].nil?? '' : "AND sm.analysis_name = '#{opts[:filter]}'"
    category      = opts[:category] || 'category'
    scope         = scope.nil? || scope == '1=1' ? '1=1' : "sm.#{scope}"
    grouping      = ", #{level}"
    range_join    = "a.#{level}"
    range_area    = 'range_area'
    range_percent = 'percent_range_assessed'
    display_col   = 'surveytypes.surveytype'
    display_join  = 'JOIN surveytypes ON surveytypes.category = sm.category'

    if level == 'country'
      range_table = 'country_range_totals'
      range_area  = '"RANGE_AREA"'
      range_percent = '"CATEGORY_PERCENT_RANGE_ASSESSED"'
    elsif level == 'region'
      range_table = 'regional_range_totals'
    elsif level == 'continent'
      range_table = 'continental_range_totals'
      grouping    = ''
      range_join  = "'Africa'"
    else
      raise Exception.new "Invalid level #{level}"
    end

    if category == 'reason_change'
      display_col = 'cause_of_changes.name'
      display_join = 'JOIN cause_of_changes ON cause_of_changes.code = sm.reason_change'
    end

    <<-SQL
      SELECT
        a.#{category},
        a.display,
        a."AREA",
        a."AREA" / range.#{range_area} * 100 as "CATEGORY_RANGE_ASSESSED",
        range.#{range_area} as range_area,
        range.#{range_percent} as percent_range_assessed
      FROM (
        SELECT
          analysis_name, analysis_year,
          #{display_col} as display,
          sm.#{category}#{grouping}, sum(area_sqkm) as "AREA"
        FROM
          survey_range_intersection_metrics_add sm
        #{display_join}
        WHERE
          sm.analysis_year = #{year}
          #{analysis_name}
          AND #{scope}
        GROUP BY sm.analysis_name, sm.analysis_year, #{display_col}, sm.#{category}#{grouping}
      ) a
      JOIN #{range_table} range ON range.#{level} = #{range_join} AND 
        range.analysis_year = a.analysis_year AND range.analysis_name = a.analysis_name
      ORDER BY a.#{category}
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
          x.analysis_name,
          x.analysis_year,
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) as "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          sum(distinct "ASSESSED_RANGE") AS "ASSESSED_RANGE",
          sum(distinct "RANGE_AREA") AS "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year AND
          x.analysis_name = crt.analysis_name AND x.analysis_year = crt.analysis_year
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.analysis_name, x.analysis_year, x.region
      ) p
      JOIN regional_range_totals rrt ON rrt.region = p.region AND rrt.analysis_name = p.analysis_name AND rrt.analysis_year = p.analysis_year
      JOIN continental_range_totals cont ON continent = 'Africa' AND cont.analysis_name = rrt.analysis_name AND cont.analysis_year = rrt.analysis_year
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
          x.analysis_name,
          x.analysis_year,
          x.country,
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) as "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          "ASSESSED_RANGE",
          "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year AND crt.analysis_name = x.analysis_name
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.analysis_name, x.analysis_year, x.country, x.region, "RANGE_AREA", "ASSESSED_RANGE"
      ) p
      JOIN regional_range_totals rrt ON rrt.region = p.region AND rrt.analysis_name = p.analysis_name AND rrt.analysis_year = p.analysis_year
      JOIN continental_range_totals cont ON continent = 'Africa' AND cont.analysis_name = rrt.analysis_name AND cont.analysis_year = rrt.analysis_year
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
          x.analysis_name,
          x.analysis_year,
          x.region,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) AS "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          range_assessed as "ASSESSED_RANGE",
          range_area as "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN regional_range_totals rt ON x.analysis_name = rt.analysis_name AND x.analysis_year = rt.analysis_year AND rt.region = x.region
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.analysis_name, x.analysis_year, x.region, "RANGE_AREA", "ASSESSED_RANGE"
      ) p
      JOIN continental_range_totals cont ON continent = 'Africa' AND p.analysis_name = cont.analysis_name AND p.analysis_year = cont.analysis_year
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
          x.analysis_name,
          x.analysis_year,
          sum(x."ESTIMATE") as "ESTIMATE",
          1.96*sqrt(sum(x."POPULATION_VARIANCE")) AS "CONFIDENCE",
          sum(x."GUESS_MIN") as "GUESS_MIN",
          sum(x."GUESS_MAX") as "GUESS_MAX",
          sum(distinct range_assessed) as "ASSESSED_RANGE",
          sum(distinct range_area) as "RANGE_AREA"
        FROM estimate_factors_analyses_categorized_totals_for_add x
        JOIN regional_range_totals rt ON rt.region = x.region AND rt.analysis_name = x.analysis_name AND rt.analysis_year = x.analysis_year
        WHERE
          x.analysis_year = #{year}
          #{analysis_name}
        GROUP BY x.analysis_name, x.analysis_year
      ) p
      JOIN continental_range_totals cont ON continent = 'Africa' AND cont.analysis_name = p.analysis_name AND cont.analysis_year = p.analysis_year
    SQL
  end

  def alt_dpps scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND s.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
      "CATEGORY",
      "SURVEYTYPE",
      st.display_order,
      sum("ESTIMATE") AS "ESTIMATE",
      1.96*sqrt(sum("POPULATION_VARIANCE")) AS "CONFIDENCE",
      sum("GUESS_MIN") AS "GUESS_MIN",
      sum("GUESS_MAX") AS "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_totals_for_add s
      JOIN surveytypes st ON st.category = "CATEGORY"
      WHERE
        s.analysis_year = #{year}
        #{analysis_name}
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE", display_order
      ORDER BY st.display_order
    SQL
  end

  def alt_dpps_totals scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND s.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        SUM("ESTIMATE") AS "ESTIMATE",
        1.96*sqrt(sum("POPULATION_VARIANCE")) AS "CONFIDENCE",
        SUM("GUESS_MIN") AS "GUESS_MIN",
        SUM("GUESS_MAX") AS "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_totals_for_add s
      WHERE
        s.analysis_year = #{year}
        #{analysis_name}
        AND #{scope}
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
