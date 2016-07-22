DROP VIEW IF EXISTS appendix_2_add CASCADE;
CREATE OR REPLACE VIEW appendix_2_add AS
  SELECT
    analysis_name,
    analysis_year,
    region,
    country,
    replacement_name,
    estimate_type,
    estimate,
    confidence
  FROM (
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.country,
      l.sort_key,
      l.replacement_name,
      l.estimate_type,
      sum(e.population_estimate) estimate,
      1.96*sqrt(sum(e.population_variance)) confidence
    FROM ioc_add_new_base e
    JOIN estimate_locator l ON l.analysis_name = e.analysis_name AND l.analysis_year = e.analysis_year
      AND l.input_zone_id = e.input_zone_id
    WHERE e.reason_change = 'RS'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, l.replacement_name, l.estimate_type, l.sort_key
    UNION
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.country,
      l.sort_key,
      l.replacement_name,
      l.estimate_type,
      sum(e.population_estimate) estimate,
      1.96*sqrt(sum(e.population_variance)) confidence
    FROM ioc_add_replaced_base e
    JOIN estimate_locator l ON l.analysis_name = e.analysis_name AND l.analysis_year = e.analysis_year
      AND l.input_zone_id = e.input_zone_id
    WHERE e.reason_change = 'RS'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.country, l.replacement_name, l.estimate_type, l.sort_key
  ) i
  ORDER BY analysis_name, region, country, sort_key, replacement_name, analysis_year;

