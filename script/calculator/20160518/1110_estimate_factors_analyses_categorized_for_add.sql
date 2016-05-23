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
      e.population_estimate,
      0 AS population_variance,
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
      e.population_estimate,
      0 AS population_variance,
      (e.population_estimate - e.actually_seen) AS population_lower_confidence_limit,
      (e.population_estimate - e.actually_seen) AS population_upper_confidence_limit,
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
      e.population_estimate,
      0 AS population_variance,
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
      e.population_estimate,
      0 as population_variance,
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
      e.population_estimate,
      0 as population_variance,
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
    WHERE e.category = 'D' AND e.site_name = 'Rest of Gabon'
  ) m
  JOIN surveytypes st ON m.category = st.category
  JOIN population_submissions ps ON ps.id = m.population_submission_id
  JOIN submissions s ON ps.submission_id = s.id
  JOIN countries c ON s.country_id = c.id
  JOIN regions r ON c.region_id = r.id
  JOIN continents ct ON r.continent_id = ct.id;

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_sums_for_add AS
  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    sum(e.population_variance) as "POPULATION_VARIANCE",
    0 as "GUESS_MIN",
    0 as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category IN ('H', 'I', 'J', 'K', 'L', 'M', 'N')
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'D' OR e.category = 'E'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, country, region

  UNION

  SELECT
    e.category AS "CATEGORY",
    e.surveytype AS "SURVEYTYPE",
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    0 as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category = 'F' OR e.category = 'G'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, country, region

  ORDER BY "CATEGORY";

CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_totals_for_add AS
  SELECT
   "CATEGORY",
   "SURVEYTYPE",
   analysis_year,
   analysis_name,
   continent,
   country,
   region,
   sum("ESTIMATE") AS "ESTIMATE",
   sum("POPULATION_VARIANCE") as "POPULATION_VARIANCE",
   sum("GUESS_MIN") as "GUESS_MIN",
   sum("GUESS_MAX") as "GUESS_MAX"
  FROM estimate_factors_analyses_categorized_sums_for_add
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, continent, country, region;

DROP VIEW IF EXISTS estimate_locator_with_geometry_add;
CREATE VIEW estimate_locator_with_geometry_add AS
  SELECT
    g.id as id,
    l.*,
    g.geom
  FROM survey_geometries g
  JOIN estimate_factors f
    ON f.survey_geometry_id = g.id
  JOIN estimate_factors_analyses_categorized_for_add l
    ON l.input_zone_id = f.input_zone_id;
