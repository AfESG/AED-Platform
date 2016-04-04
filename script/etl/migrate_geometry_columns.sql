# Migrate to use "geom" column consistently (because "geometry"
# conflicts with RGeo) and remove leftover dependencies on
# externally imported geometries

DROP VIEW estimate_locator_with_geometry CASCADE;
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
 SELECT estimate_locator_with_geometry.input_zone_id,
    estimate_locator_with_geometry.analysis_name,
    estimate_locator_with_geometry.analysis_year,
    sum(st_area(estimate_locator_with_geometry.geom::geography, true)) / 1000000::double precision AS area_sqkm
   FROM estimate_locator_with_geometry
  GROUP BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year
  ORDER BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year;

alter table survey_geometries drop column geometry;

drop table if exists inputzone_2013_africa_final4b cascade;

drop table if exists survey_range_intersections;
drop table if exists survey_range_intersections_add;

create table survey_range_intersections as
  select analysis_name, analysis_year, region, category, l.country, range_quality,
    ST_Intersection(ST_MakeValid(ST_Force2D(ST_SetSRID(geom,4326))),ST_MakeValid(ST_Force2D(ST_SetSRID(range_geometry,4326))))
  from estimate_locator_with_geometry l
  join country_range c on ST_Intersects(ST_SetSRID(geom,4326),ST_SetSRID(range_geometry,4326))
  where range=1;

create view survey_range_intersections_add as
  select * from survey_range_intersections;

delete from survey_range_intersection_metrics;
insert into survey_range_intersection_metrics
select analysis_name, analysis_year, region, range_quality, category, country,
    ST_Area(st_intersection::geography,true)/1000000 area_sqkm
  from survey_range_intersections_add;

drop table if exists survey_range_intersection_metrics_add;

create view survey_range_intersection_metrics_add as
  select * from survey_range_intersection_metrics;
