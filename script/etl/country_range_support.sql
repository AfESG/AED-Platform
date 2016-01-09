DROP VIEW IF EXISTS country_range_by_category CASCADE;
CREATE VIEW country_range_by_category AS
  SELECT
	  a.region,
	  a.country,
    a.category,
    a.analysis_year,
    a.analysis_name,
    a."AREA" as "ASSESSED_RANGE",
    a."AREA" / rt.range_area * 100 as "CATEGORY_PERCENT_RANGE_ASSESSED",
    rt.range_area as "RANGE_AREA"
  FROM (
    SELECT
      category,
      region,
      country,
      analysis_year,
      analysis_name,
      sum(area_sqkm) as "AREA"
    FROM
      survey_range_intersection_metrics sm
    GROUP BY category, region, country, analysis_year, analysis_name
  ) a
  JOIN (
    SELECT
      country,
      sum(area_sqkm) as range_area
    FROM country_range_metrics
    GROUP BY country
  ) rt ON rt.country = a.country
  ORDER BY country, category;

DROP VIEW IF EXISTS country_range_totals CASCADE;
CREATE VIEW country_range_totals AS
  SELECT
	  a.region,
    a.country,
    a.analysis_year,
    a.analysis_name,
    sum("ASSESSED_RANGE") as "ASSESSED_RANGE",
    sum("CATEGORY_PERCENT_RANGE_ASSESSED") as "CATEGORY_PERCENT_RANGE_ASSESSED",
    "RANGE_AREA"
  FROM
    country_range_by_category a
  GROUP BY region, country, analysis_year, analysis_name, "RANGE_AREA"
  ORDER BY region, country, analysis_year, analysis_name, "RANGE_AREA";

DROP VIEW IF EXISTS estimate_locator_areas CASCADE;
CREATE VIEW estimate_locator_areas AS SELECT estimate_locator_with_geometry.input_zone_id,
    estimate_locator_with_geometry.analysis_name,
    estimate_locator_with_geometry.analysis_year,
    sum(st_area(estimate_locator_with_geometry.geometry::geography, true)) / 1000000::double precision AS area_sqkm
   FROM estimate_locator_with_geometry
  GROUP BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year
  ORDER BY estimate_locator_with_geometry.input_zone_id, estimate_locator_with_geometry.analysis_name, estimate_locator_with_geometry.analysis_year;
