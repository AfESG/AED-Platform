DROP VIEW IF EXISTS estimate_factors_analyses_categorized_for_add;
CREATE VIEW estimate_factors_analyses_categorized_for_add AS
  SELECT
    e.estimate_type,
    e.category,
    surveytype,
    e.analysis_name,
    e.analysis_year,
    e.completion_year,
    r.name as region,
    c.name as country,
    e.site_name,
    e.population_estimate,
    e.population_variance,
    CASE
      WHEN e.category in ('D', 'E') AND (e.population_lower_confidence_limit is null OR e.population_upper_confidence_limit is null OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0)) THEN e.population_estimate
      ELSE e.population_lower_confidence_limit
    END as population_lower_confidence_limit,
    CASE
      WHEN e.category in ('D', 'E') AND (e.population_lower_confidence_limit is null OR e.population_upper_confidence_limit is null OR (e.population_lower_confidence_limit = 0 AND e.population_upper_confidence_limit = 0)) THEN e.population_estimate
      ELSE e.population_upper_confidence_limit
    END as population_upper_confidence_limit,
    e.actually_seen
  FROM
    estimate_factors_analyses_categorized e
  JOIN population_submissions ps ON ps.id = e.population_submission_id
  JOIN submissions s ON ps.submission_id = s.id
  JOIN countries c ON s.country_id = c.id
  JOIN regions r ON c.region_id = r.id
  JOIN surveytypes st ON e.category = st.category;
