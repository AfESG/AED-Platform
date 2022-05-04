CREATE OR REPLACE VIEW estimate_factors_analyses_categorized_zones_for_add AS
  SELECT
    zone.analysis_name,
    zone.analysis_year,
    el.sort_key,
    el.population,
    zone.country,
    zone.site_name,
    zone.phenotype,
    zone.phenotype_basis,
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
        e.phenotype,
        e.phenotype_basis,
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
        e.phenotype,
        e.phenotype_basis,
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

