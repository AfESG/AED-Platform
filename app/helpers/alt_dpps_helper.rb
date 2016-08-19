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
    display = number_with_delimiter(value.to_f.round(opts[:precision] || 0))
    if opts[:zeroes] == false && display.to_f <= 1
      display = "#{"%0.2f" % display}"[1..-1]
    end
    content_tag :td, display, defaults
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
      numeric_cell round ? rounded(num) : num, opts
    end
  rescue StandardError => e
    error_cell e.message
  end

  def alt_dpps_causes_of_change scope, year, filter=nil
    sql = { analysis_name: '' }
    apply_table_for_scope scope, sql
    if filter
      sql[:analysis_name] = "AND e.analysis_name = '#{filter}'"
    end
    <<-SQL
      SELECT
        cc.name AS "CAUSE",
        cc.display_order AS "SEQUENCE",
        e.estimate AS "ESTIMATE",
        e.confidence AS "CONFIDENCE",
        e.guess_min AS "GUESS_MIN",
        e.guess_max AS "GUESS_MAX"
      FROM add_sums_#{sql[:table]}_category_reason e
      JOIN cause_of_changes cc ON cc.code = e.reason_change
      WHERE
        e.analysis_year = #{year}
        #{sql[:analysis_name]}
        AND #{scope}
      ORDER BY cc.display_order
    SQL
  end

  def alt_dpps_causes_of_change_sums scope, year, filter=nil
    sql = { analysis_name: '' }
    apply_table_for_scope scope, sql
    if filter
      sql[:analysis_name] = "AND e.analysis_name = '#{filter}'"
    end
    <<-SQL
      SELECT
        e.estimate AS "ESTIMATE",
        e.confidence AS "CONFIDENCE",
        e.guess_min AS "GUESS_MIN",
        e.guess_max AS "GUESS_MAX"
      FROM add_totals_#{sql[:table]}_category_reason e
      WHERE
        e.analysis_year = #{year}
        #{sql[:analysis_name]}
        AND #{scope}
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

  def alt_dpps_country_stats country, year, filter=nil
    analysis_name = filter.nil?? '' : "AND e.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        *
      FROM estimate_factors_analyses_categorized_zones_for_add e
      WHERE
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.country = '#{country.gsub("\'","\'\'")}'
    SQL
  end

  def alt_dpps_region_stats_sums scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        x."ESTIMATE",
        x."CONFIDENCE",
        x."GUESS_MIN",
        x."GUESS_MAX",
        x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX") as "PF",
        rrt.range_assessed / rrt.range_area as "ARF",
        (x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (rrt.range_assessed / rrt.range_area) AS "IQI",
        (rrt.range_area / cont.range_area) AS "CRF",
        log((1+(x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (rrt.range_assessed / rrt.range_area)) / (rrt.range_area / cont.range_area)) AS "PFS",
        rrt.range_assessed AS "ASSESSED_RANGE",
        rrt.range_area as "RANGE_AREA",
        rrt.range_area / rrt.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        rrt.range_assessed / rrt.range_area * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM estimate_factors_analyses_categorized_totals_region_for_add x
      JOIN regional_range_totals rrt ON rrt.region = x.region AND rrt.analysis_name = x.analysis_name AND rrt.analysis_year = x.analysis_year
      JOIN continental_range_totals cont ON cont.continent = 'Africa' AND cont.analysis_name = rrt.analysis_name AND cont.analysis_year = rrt.analysis_year
      WHERE
        x.analysis_year = #{year}
        #{analysis_name}
        AND x.#{scope}
      ORDER BY x.region
    SQL
  end

  def alt_dpps_region_stats scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        x.country,
        x."ESTIMATE",
        x."CONFIDENCE",
        x."GUESS_MIN",
        x."GUESS_MAX",
        x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX") as "PF",
        crt."ASSESSED_RANGE" / crt."RANGE_AREA" as "ARF",
        (x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA") AS "IQI",
        (crt."RANGE_AREA" / cont.range_area) AS "CRF",
        log((1+(x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (crt."ASSESSED_RANGE" / crt."RANGE_AREA")) / (crt."RANGE_AREA" / cont.range_area)) AS "PFS",
        crt."ASSESSED_RANGE",
        crt."RANGE_AREA",
        crt."RANGE_AREA" / rrt.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        crt."ASSESSED_RANGE" / crt."RANGE_AREA" * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM estimate_factors_analyses_categorized_totals_country_for_add x
      JOIN country_range_totals crt ON crt.country = x.country AND crt.analysis_year = x.analysis_year AND crt.analysis_name = x.analysis_name
      JOIN regional_range_totals rrt ON rrt.region = crt.region AND rrt.analysis_name = crt.analysis_name AND rrt.analysis_year = crt.analysis_year
      JOIN continental_range_totals cont ON cont.continent = 'Africa' AND cont.analysis_name = rrt.analysis_name AND cont.analysis_year = rrt.analysis_year
      WHERE
        x.analysis_year = #{year}
        #{analysis_name}
        AND x.#{scope}
      ORDER BY x.country
    SQL
  end

  def alt_dpps_continental_stats scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        x.region,
        x."ESTIMATE",
        x."CONFIDENCE",
        x."GUESS_MIN",
        x."GUESS_MAX",
        x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX") as "PF",
        rt.range_assessed / rt.range_area as "ARF",
        (x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (rt.range_assessed / rt.range_area) AS "IQI",
        (rt.range_area / cont.range_area) AS "CRF",
        log((1+(x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX")) * (rt.range_assessed / rt.range_area)) / (rt.range_area / cont.range_area)) AS "PFS",
        rt.range_assessed as "ASSESSED_RANGE",
        rt.range_area as "RANGE_AREA",
        rt.range_area / cont.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        rt.range_assessed / rt.range_area * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM estimate_factors_analyses_categorized_totals_region_for_add x
      JOIN regional_range_totals rt ON x.analysis_name = rt.analysis_name AND x.analysis_year = rt.analysis_year AND rt.region = x.region
      JOIN continental_range_totals cont ON cont.continent = 'Africa' AND rt.analysis_name = cont.analysis_name AND rt.analysis_year = cont.analysis_year
      WHERE
        x.analysis_year = #{year}
        #{analysis_name}
      --GROUP BY x.analysis_name, x.analysis_year, x.region, rt.range_area
      ORDER BY x.region
    SQL
  end

  def alt_dpps_continental_stats_sums scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND x.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        x."ESTIMATE",
        x."CONFIDENCE",
        x."GUESS_MIN",
        x."GUESS_MAX",
        x."ESTIMATE" / (x."ESTIMATE" + x."CONFIDENCE" + x."GUESS_MAX") as "PF",
        cont.range_assessed / cont.range_area as "ARF",
        ("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * (cont.range_assessed / cont.range_area) AS "IQI",
        (cont.range_area / cont.range_area) AS "CRF",
        log((1+("ESTIMATE" / ("ESTIMATE" + "CONFIDENCE" + "GUESS_MAX")) * (cont.range_assessed / cont.range_area)) / (cont.range_area / cont.range_area)) AS "PFS",
        cont.range_assessed as "ASSESSED_RANGE",
        cont.range_area as "RANGE_AREA",
        cont.range_area / cont.range_area * 100 AS "PERCENT_OF_RANGE_COVERED",
        cont.range_assessed / cont.range_area * 100 as "PERCENT_OF_RANGE_ASSESSED"
      FROM estimate_factors_analyses_categorized_totals_continent_for_add x
      JOIN continental_range_totals cont ON x.continent = cont.continent AND cont.analysis_name = x.analysis_name AND cont.analysis_year = x.analysis_year
      WHERE x.analysis_year = #{year}
        #{analysis_name}
        AND x.continent = 'Africa'
    SQL
  end

  def alt_dpps scope, year, filter=nil
    sql = {}
    apply_table_for_scope scope, sql
    analysis_name = filter.nil?? '' : "AND s.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        "CATEGORY",
        "SURVEYTYPE",
        st.display_order,
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_sums_#{sql[:table]}_for_add s
      JOIN surveytypes st ON st.category = s."CATEGORY"
      WHERE
        s.analysis_year = #{year}
        #{analysis_name}
        AND #{scope}
      ORDER BY st.display_order
    SQL
  end

  def alt_dpps_totals scope, year, filter=nil
    sql = {}
    apply_table_for_scope scope, sql
    analysis_name = filter.nil?? '' : "AND s.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        "ESTIMATE",
        "CONFIDENCE",
        "GUESS_MIN",
        "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_totals_#{sql[:table]}_for_add s
      WHERE
        s.analysis_year = #{year}
        #{analysis_name}
        AND #{scope}
    SQL
  end

  private

  def apply_table_for_scope scope, sql
    if scope.include? 'country'
      sql[:table] = 'country'
    elsif scope.include? 'region'
      sql[:table] = 'region'
    else
      sql[:table] = 'continent'
    end
  end

end
