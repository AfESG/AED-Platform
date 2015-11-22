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

  def is_blank_cell? row, column
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
    totals[column] ||= 0
    value = row[column] || 0
    if value.nil?
      unused_cell
    else
      num = value.to_f
      totals[column] += num
      round_area_cell num, opts
    end
  end

  def add_and_display_cell row, column, totals, opts
    totals[column] ||= 0
    round = opts[:round] || false
    value = row[column]
    if value.nil? || is_blank_cell?(row, column)
      unused_cell
    else
      num = value.to_i
      totals[column] += num
      defaults = { class: 'numeric' }
      defaults.merge!(opts[:attrs]) if opts[:attrs]
      content_tag :td, number_with_delimiter(round ? rounded(num) : num), defaults
    end
  end

  def alt_dpps_area scope, year, filter=nil
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
          survey_range_intersection_metrics sm
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

  def alt_dpps scope, year, filter=nil
    analysis_name = filter.nil?? '' : "AND e.analysis_name = '#{filter}'"
    <<-SQL
      SELECT
        e.category as "CATEGORY",
        surveytype as "SURVEYTYPE",
        sum(e.population_estimate) as "ESTIMATE",
        0 as "CONFIDENCE",
        0 as "GUESS_MIN",
        0 as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.category = 'A'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        e.category as "CATEGORY",
        surveytype as "SURVEYTYPE",
        sum(e.population_estimate) as "ESTIMATE",
        1.96*sqrt(sum(e.population_variance)) as "CONFIDENCE",
        0 as "GUESS_MIN",
        0 as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.category = 'B'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        e.category as "CATEGORY",
        surveytype as "SURVEYTYPE",
        sum(e.actually_seen) as "ESTIMATE",
        0 as "CONFIDENCE",
        sum(e.population_estimate) - sum(e.actually_seen) as "GUESS_MIN",
        sum(e.population_estimate) - sum(e.actually_seen) as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.category = 'C'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        e.category as "CATEGORY",
        surveytype as "SURVEYTYPE",
        sum(e.actually_seen) as "ESTIMATE",
        0 as "CONFIDENCE",
        sum(e.population_lower_confidence_limit) - sum(e.actually_seen) as "GUESS_MIN",
        sum(e.population_upper_confidence_limit) - sum(e.actually_seen) as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.category = 'D'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        e.category as "CATEGORY",
        surveytype as "SURVEYTYPE",
        sum(e.actually_seen) as "ESTIMATE",
        0 as "CONFIDENCE",
        sum(e.population_lower_confidence_limit) - sum(e.actually_seen) as "GUESS_MIN",
        sum(e.population_upper_confidence_limit) - sum(e.actually_seen) as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.completion_year > #{year - 10}
        AND e.category = 'E'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        'F' as "CATEGORY",
        'Degraded Data' as "SURVEYTYPE",
        0 as "ESTIMATE",
        0 as "CONFIDENCE",
        sum(e.population_estimate) as "GUESS_MIN",
        sum(e.population_estimate) as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE 
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.completion_year <= #{year - 10}
        AND e.category = 'E'
        AND #{scope}
      GROUP BY "CATEGORY", "SURVEYTYPE"

      UNION

      SELECT
        'G' as "CATEGORY",
        'Modeled Extrapolation' as "SURVEYTYPE",
        0 as "ESTIMATE",
        0 as "CONFIDENCE",
        sum(e.population_estimate) as "GUESS_MIN",
        sum(e.population_estimate) as "GUESS_MAX"
      FROM
        estimate_factors_analyses_categorized_for_add e
      WHERE
        e.analysis_year = #{year}
        #{analysis_name}
        AND e.category = 'D'
        AND e.site_name = 'Rest of Gabon'
        AND #{scope}

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
