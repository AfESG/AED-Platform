CREATE OR REPLACE VIEW input_zone_export AS
 SELECT
    l.analysis_name,
    l.analysis_year,
    l.continent,
    l.region,
    l.country,
    l.replacement_name as inpzone,
    l.site_name as site,
    l.stratum_name as stratum,
    l.input_zone_id as strcode,
    l.estimate_type as est_type,
    l.category,
    l.completion_year as year,
    l.reason_change as rc,
    l.citation as full_cit,
    l.short_citation as short_cit,
    l.population_estimate as estimate,
    l.population_variance as variance,
    l.population_standard_error as std_err,
    l.population_confidence_interval as ci,
    l.population_lower_confidence_limit as lcl,
    l.population_upper_confidence_limit as ucl,
    l.lcl95 as lcl95,
    l.quality_level as quality,
    l.actually_seen as seen,
    l.stratum_area as area_rep,
    ST_Area(g.geometry::geography,true)/1000000 as area_calc,
    g.geometry
   FROM estimate_locator l
     JOIN estimate_factors f ON l.input_zone_id = f.input_zone_id
     JOIN survey_geometries g ON f.survey_geometry_id = g.id
   ORDER BY
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    inpzone,
    site,
    stratum
;
