DROP VIEW IF EXISTS estimate_locator_with_geometry CASCADE;
CREATE VIEW estimate_locator_with_geometry AS
 SELECT g.id,
    l.estimate_type,
    l.input_zone_id,
    l.population_submission_id,
    l.site_name,
    l.stratum_name,
    l.stratum_area,
    l.completion_year,
    l.analysis_name,
    l.analysis_year,
    l.age,
    l.replacement_name,
    l.reason_change,
    l.citation,
    l.short_citation,
    l.population_estimate,
    l.population_variance,
    l.population_standard_error,
    l.population_confidence_interval,
    l.population_lower_confidence_limit,
    l.population_upper_confidence_limit,
    l.quality_level,
    l.actually_seen,
    l.lcl95,
    l.category,
    l.country,
    l.region,
    l.continent,
    g.geom
   FROM survey_geometries g
     JOIN estimate_factors f ON f.survey_geometry_id = g.id
     JOIN estimate_locator l ON l.input_zone_id = f.input_zone_id;

CREATE VIEW estimate_locator_areas AS
 SELECT e.input_zone_id,
    e.analysis_name,
    e.analysis_year,
    sum(st_area(e.geom::geography, true)) / 1000000::double precision AS area_sqkm
   FROM estimate_locator_with_geometry e
  GROUP BY e.input_zone_id, e.analysis_name, e.analysis_year
  ORDER BY e.input_zone_id, e.analysis_name, e.analysis_year;
