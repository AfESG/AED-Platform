DROP VIEW IF EXISTS estimate_factors_analyses_categorized_totals_for_add CASCADE;
DROP VIEW IF EXISTS estimate_factors_analyses_categorized_sums_for_add CASCADE;

CREATE VIEW estimate_factors_analyses_categorized_sums_for_add AS
  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    sum(e.population_estimate) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    0 as "GUESS_MIN",
    0 as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'A'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    sum(e.population_estimate) as "ESTIMATE",
    sum(e.population_variance) as "POPULATION_VARIANCE",
    0 as "GUESS_MIN",
    0 as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'B'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    sum(e.actually_seen) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_estimate) - sum(e.actually_seen) as "GUESS_MIN",
    sum(e.population_estimate) - sum(e.actually_seen) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    sum(e.actually_seen) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) - sum(e.actually_seen) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) - sum(e.actually_seen) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'D'
    AND e.site_name <> 'Rest of Gabon'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    e.category as "CATEGORY",
    surveytype as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    sum(e.actually_seen) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) - sum(e.actually_seen) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) - sum(e.actually_seen) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.completion_year > 2003
    AND e.category = 'E'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    'F' as "CATEGORY",
    'Degraded Data' as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    0 as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_estimate) as "GUESS_MIN",
    sum(e.population_estimate) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.completion_year <= 2003
    AND e.category = 'E'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  UNION

  SELECT
    'G' as "CATEGORY",
    'Modeled Extrapolation' as "SURVEYTYPE",
    analysis_year,
    analysis_name,
    country,
    region,
    0 as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_estimate) as "GUESS_MIN",
    sum(e.population_estimate) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category = 'D'
    AND e.site_name = 'Rest of Gabon'
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region

  ORDER BY "CATEGORY";

CREATE VIEW estimate_factors_analyses_categorized_totals_for_add AS
  SELECT
   "CATEGORY",
   "SURVEYTYPE",
   analysis_year,
   analysis_name,
   country,
   region,
   sum("ESTIMATE") AS "ESTIMATE",
   sum("POPULATION_VARIANCE") as "POPULATION_VARIANCE",
   sum("GUESS_MIN") as "GUESS_MIN",
   sum("GUESS_MAX") as "GUESS_MAX"
  FROM estimate_factors_analyses_categorized_sums_for_add
  GROUP BY "CATEGORY", "SURVEYTYPE", analysis_year, analysis_name, country, region;
