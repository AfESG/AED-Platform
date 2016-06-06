CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_for_add AS
  SELECT
    m.estimate_type,
    m.category,
    (st.surveytype || '')::varchar as surveytype,
    m.analysis_name,
    m.analysis_year,
    m.completion_year,
    ct.name as continent,
    r.name as region,
    c.name as country,
    m.site_name,
    m.best_estimate,
    m.best_population_variance,
    m.population_estimate,
    m.population_variance,
    m.population_lower_confidence_limit,
    m.population_upper_confidence_limit,
    m.actually_seen,
    m.input_zone_id,
    m.population_submission_id,
    m.stratum_name,
    m.stratum_area,
    m.age,
    m.replacement_name,
    m.reason_change,
    m.citation,
    m.short_citation,
    m.population_standard_error,
    m.population_confidence_interval,
    m.lcl95,
    m.quality_level
  FROM (
    SELECT e.estimate_type,
      CASE
      WHEN e.estimate_type = 'GD' THEN 'N'
      WHEN e.estimate_type = 'AT' THEN 'H'
      WHEN e.estimate_type = 'GT' THEN 'I'
      WHEN e.estimate_type = 'IR' THEN 'M'
      ELSE 'U'
      END AS category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      e.population_estimate as best_estimate,
      0 AS best_population_variance,
      e.population_estimate,
      e.population_variance,
      0 AS population_lower_confidence_limit,
      0 AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'A'
   UNION
    SELECT e.estimate_type,
      CASE
      WHEN e.estimate_type = 'DC' THEN 'L'
      WHEN e.estimate_type = 'AS' THEN 'J'
      WHEN e.estimate_type = 'GS' THEN 'K'
      ELSE 'U'
      END AS category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      CASE
        WHEN e.population_estimate IS NULL OR e.population_estimate = 0 THEN e.actually_seen
        ELSE e.population_estimate
      END AS best_estimate,
      e.population_variance as best_population_variance,
      e.population_estimate,
      e.population_variance,
      0 AS population_lower_confidence_limit,
      0 AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    JOIN surveytypes st ON e.category = st.category
    WHERE e.category = 'B'
   UNION
    SELECT e.estimate_type,
      e.category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      e.actually_seen as best_estimate,
      0 as best_population_variance,
      e.population_estimate,
      e.population_variance,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_lower_confidence_limit - e.actually_seen
      END AS population_lower_confidence_limit,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_upper_confidence_limit - e.actually_seen
      END AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'C'
   UNION
    SELECT e.estimate_type,
      e.category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      e.actually_seen as best_estimate,
      0 as best_population_variance,
      e.population_estimate,
      e.population_variance,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_lower_confidence_limit - e.actually_seen
      END AS population_lower_confidence_limit,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_upper_confidence_limit - e.actually_seen
      END AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'D' AND e.site_name <> 'Rest of Gabon'
   UNION
    SELECT e.estimate_type,
      e.category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      0 as best_estimate,
      0 as best_population_variance,
      0 as population_estimate,
      0 as population_variance,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_lower_confidence_limit - e.actually_seen
      END AS population_lower_confidence_limit,
      CASE
        WHEN e.population_lower_confidence_limit IS NULL OR e.population_upper_confidence_limit IS NULL 
          OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0) 
          THEN e.population_estimate - e.actually_seen
        ELSE e.population_upper_confidence_limit - e.actually_seen
      END AS population_upper_confidence_limit,
      0 as actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'E' AND e.completion_year > e.analysis_year - 10
   UNION
    SELECT e.estimate_type,
      'F' AS category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      0 AS best_estimate,
      0 as best_population_variance,
      e.population_estimate,
      e.population_variance,
      e.population_estimate AS population_lower_confidence_limit,
      e.population_estimate AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'E' AND e.completion_year <= e.analysis_year - 10
   UNION
    SELECT e.estimate_type,
      'G' as category,
      e.analysis_name,
      e.analysis_year,
      e.completion_year,
      e.site_name,
      0 as best_estimate,
      0 as best_population_variance,
      e.population_estimate,
      e.population_variance,
      e.population_estimate AS population_lower_confidence_limit,
      e.population_estimate AS population_upper_confidence_limit,
      e.actually_seen,
      e.input_zone_id,
      e.population_submission_id,
      e.stratum_name,
      e.stratum_area,
      e.age,
      e.replacement_name,
      e.reason_change,
      e.citation,
      e.short_citation,
      e.population_confidence_interval,
      e.population_standard_error,
      e.lcl95,
      e.quality_level
    FROM estimate_factors_analyses_categorized e
    WHERE e.category = 'G' OR (e.category = 'D' AND e.site_name = 'Rest of Gabon')
  ) m
  JOIN surveytypes st ON m.category = st.category
  JOIN population_submissions ps ON ps.id = m.population_submission_id
  JOIN submissions s ON ps.submission_id = s.id
  JOIN countries c ON s.country_id = c.id
  JOIN regions r ON c.region_id = r.id
  JOIN continents ct ON r.continent_id = ct.id;

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_zones_for_add AS
  SELECT
    zone.analysis_name,
    zone.analysis_year,
    el.sort_key,
    el.population,
    zone.country,
    zone.site_name,
    zone.stratum_name,
    zone.replacement_name,
    zone.population_variance,
    CASE
      WHEN zone.reason_change = 'NC' THEN '-'
      ELSE zone.reason_change
    END AS "ReasonForChange",
    zone.population_submission_id,
    zone.method_and_quality,
    zone."CATEGORY",
    zone."CYEAR",
    zone."ESTIMATE",
    1.96*sqrt(zone.population_variance) AS "CONFIDENCE",
    zone."GUESS_MIN",
    zone."GUESS_MAX",
    zone."CL95",
    zone."REFERENCE",
    round(log((1+(zone."ESTIMATE" / (zone."ESTIMATE" + (1.96*sqrt(zone.population_variance)) + "GUESS_MAX" + 0.0001))) / 
          (a.area_sqkm / rm.range_area))) "PFS",
    rm.range_area "RA",
    a.area_sqkm "CALC_SQKM",
    zone."AREA_SQKM",
    CASE 
      WHEN longitude < 0 THEN to_char(abs(longitude),'999D9') || 'W'
      WHEN longitude = 0 THEN '0.0'
      ELSE to_char(abs(longitude),'999D9') || 'E'
    END "LON",
    CASE
      WHEN latitude < 0 THEN to_char(abs(latitude),'999D9') || 'S'
      WHEN latitude = 0 THEN '0.0'
      ELSE to_char(abs(latitude),'999D9') || 'N'
    END "LAT"
  FROM (
      SELECT
        e.analysis_name,
        e.analysis_year,
        e.estimate_type,
        e.country,
        e.site_name,
        e.stratum_name,
        e.replacement_name,
        e.best_population_variance as population_variance,
        e.population_confidence_interval,
        e.reason_change,
        e.population_submission_id,
        e.input_zone_id method_and_quality,
        e.category "CATEGORY",
        e.completion_year "CYEAR",
        e.best_estimate "ESTIMATE",
        e.population_lower_confidence_limit "GUESS_MIN",
        e.population_upper_confidence_limit "GUESS_MAX",
        CASE
          WHEN e.population_upper_confidence_limit IS NOT NULL THEN
            CASE WHEN e.estimate_type='O' THEN
              to_char(e.population_upper_confidence_limit-e.best_estimate,'999,999') || '*'
            ELSE
              to_char(e.population_upper_confidence_limit-e.best_estimate,'999,999')
            END
          WHEN e.population_confidence_interval IS NOT NULL THEN
            to_char(ROUND(e.population_confidence_interval),'999,999')
          ELSE ''
        END "CL95",
        e.short_citation "REFERENCE",
        e.stratum_area "AREA_SQKM"
      FROM estimate_factors_analyses_categorized_for_add e
      WHERE e.category <> 'C'
      UNION
      SELECT
        e.analysis_name,
        e.analysis_year,
        e.estimate_type,
        e.country,
        e.site_name,
        e.stratum_name,
        e.replacement_name,
        e.best_population_variance as population_variance,
        e.population_confidence_interval,
        e.reason_change,
        e.population_submission_id,
        e.input_zone_id method_and_quality,
        e.category "CATEGORY",
        e.completion_year "CYEAR",
        e.best_estimate "ESTIMATE",
        e.population_lower_confidence_limit + 1.96*sqrt(e.population_variance) "GUESS_MIN",
        e.population_upper_confidence_limit + 1.96*sqrt(e.population_variance) "GUESS_MAX",
        '' as "CL95",
        e.short_citation "REFERENCE",
        e.stratum_area "AREA_SQKM"
      FROM estimate_factors_analyses_categorized_for_add e
      WHERE e.category = 'C'
  ) zone
  JOIN estimate_locator el ON zone.method_and_quality = el.input_zone_id
    and zone.analysis_name = el.analysis_name
    and zone.analysis_year = el.analysis_year
  JOIN estimate_locator_areas a on el.input_zone_id = a.input_zone_id
    and el.analysis_name = a.analysis_name
    and el.analysis_year = a.analysis_year
  JOIN surveytypes t on t.category = zone."CATEGORY"
  JOIN population_submissions on zone.population_submission_id = population_submissions.id
  JOIN regional_range_table rm on zone.country = rm.country 
    AND zone.analysis_name = rm.analysis_name 
    AND zone.analysis_year = rm.analysis_year
  ORDER BY el.sort_key, zone.site_name, zone.stratum_name;

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_sums_country_for_add AS
  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    region,
    country,
    sum(e.best_estimate) as "ESTIMATE",
    1.96*sqrt(sum(e.best_population_variance)) as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX",
    sum(e.best_population_variance) as population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category <> 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, region, country

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    region,
    country,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MAX",
    sum(e.best_population_variance) as population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, region, country

  ORDER BY "CATEGORY";

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_totals_country_for_add AS
  SELECT
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    sum("ESTIMATE") "ESTIMATE",
    1.96*sqrt(sum(population_variance)) "CONFIDENCE",
    sum("GUESS_MIN") "GUESS_MIN",
    sum("GUESS_MAX") "GUESS_MAX"
  FROM estimate_factors_analyses_categorized_sums_country_for_add
  GROUP BY analysis_name, analysis_year, continent, region, country;

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_sums_region_for_add AS
  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    1.96*sqrt(sum(e.best_population_variance)) as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX",
    sum(e.best_population_variance) population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category <> 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MAX",
    sum(e.best_population_variance) population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, region

  ORDER BY "CATEGORY";


CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_totals_region_for_add AS
  SELECT
    analysis_name,
    analysis_year,
    continent,
    region,
    sum("ESTIMATE") "ESTIMATE",
    1.96*sqrt(sum(population_variance)) "CONFIDENCE",
    sum("GUESS_MIN") "GUESS_MIN",
    sum("GUESS_MAX") "GUESS_MAX"
  FROM estimate_factors_analyses_categorized_sums_region_for_add
  GROUP BY analysis_name, analysis_year, continent, region;


CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_sums_continent_for_add AS
  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    sum(e.best_estimate) as "ESTIMATE",
    1.96*sqrt(sum(e.population_variance)) as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX",
    sum(e.best_population_variance) population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category <> 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "CONFIDENCE",
    sum(e.population_lower_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) + 1.96*sqrt(sum(population_variance)) as "GUESS_MAX",
    sum(e.best_population_variance) population_variance
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent

  ORDER BY "CATEGORY";

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_totals_continent_for_add AS
  SELECT
    analysis_name,
    analysis_year,
    continent,
    sum("ESTIMATE") "ESTIMATE",
    1.96*sqrt(sum(population_variance)) "CONFIDENCE",
    sum("GUESS_MIN") "GUESS_MIN",
    sum("GUESS_MAX") "GUESS_MAX"
  FROM estimate_factors_analyses_categorized_sums_continent_for_add
  GROUP BY analysis_name, analysis_year, continent;

