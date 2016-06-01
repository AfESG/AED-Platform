-- Completely unnested changes.
drop view if exists changes_expanded CASCADE;
CREATE VIEW changes_expanded AS
  SELECT DISTINCT
    a.analysis_name,
    a.analysis_year,
    ch.reason_change,
    CASE
      WHEN ne.reason_change is null THEN ch.reason_change
      WHEN ne.reason_change = '-' AND ne.age >= 10 THEN 'DD'
      ELSE ne.reason_change
    END adjusted_reason_change,
    ch.country,
    ch.replaced_stratum,
    ch.new_stratum
  FROM (
    SELECT
      nc.analysis_name,
      nc.analysis_year,
      nc.reason_change,
      nc.country,
      rc.replaced_stratum,
      nc.new_stratum
    FROM (
      SELECT 
        id, analysis_name, analysis_year, reason_change, country,
        trim(unnest(regexp_split_to_array(new_strata, ','))) as new_stratum
      FROM changes
    ) nc
    LEFT JOIN (
      SELECT
        id, analysis_name, analysis_year, reason_change, country,
        new_strata,
        trim(unnest(regexp_split_to_array(replaced_strata, ','))) as replaced_stratum
      FROM changes
    ) rc ON nc.id = rc.id and nc.new_stratum = ANY((regexp_split_to_array(rc.new_strata, ',')))
    UNION
    SELECT
      analysis_name,
      analysis_year,
      reason_change,
      country,
      trim(unnest(regexp_split_to_array(replaced_strata, ','))) as replaced_stratum,
      '-'
    FROM changes
    WHERE
      new_strata = '-' OR new_strata IS NULL
  ) ch
  JOIN analyses a ON a.analysis_name = ch.analysis_name
  LEFT JOIN estimate_factors_analyses_categorized_for_add ne ON ne.analysis_name = ch.analysis_name
    AND ne.analysis_year = a.analysis_year
    AND ne.input_zone_id = ch.new_stratum;

-- Replaced strata per analysis
DROP VIEW IF EXISTS ioc_add_replaced_base CASCADE;
CREATE VIEW ioc_add_replaced_base AS
  SELECT
    e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.input_zone_id,
    e.category,
    c.adjusted_reason_change reason_change,
    e.best_estimate as population_estimate,
    e.best_population_variance as population_variance,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit
  FROM (
    SELECT DISTINCT
      analysis_name,
      analysis_year,
      replaced_stratum,
      adjusted_reason_change
    FROM changes_expanded
  ) c
  JOIN analyses a ON c.analysis_name = a.analysis_name and c.analysis_year = a.analysis_year
  JOIN estimate_factors_analyses_categorized_for_add e ON e.analysis_name = c.analysis_name
    AND e.analysis_year = a.comparison_year
    AND e.input_zone_id = c.replaced_stratum;

-- New strata per analysis
DROP VIEW IF EXISTS ioc_add_new_base CASCADE;
CREATE VIEW ioc_add_new_base AS
  SELECT
    e.analysis_name,
    e.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.input_zone_id,
    e.category,
    c.adjusted_reason_change reason_change,
    e.best_estimate as population_estimate,
    e.best_population_variance as population_variance,
    e.population_lower_confidence_limit,
    e.population_upper_confidence_limit
  FROM (
    SELECT DISTINCT
      analysis_name,
      analysis_year,
      new_stratum,
      adjusted_reason_change
    FROM changes_expanded
  ) c
  JOIN analyses a ON c.analysis_name = a.analysis_name and c.analysis_year = a.analysis_year
  JOIN estimate_factors_analyses_categorized_for_add e ON e.analysis_name = c.analysis_name
    AND e.analysis_year = a.analysis_year
    AND e.input_zone_id = c.new_stratum;

