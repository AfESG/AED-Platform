DROP VIEW IF EXISTS country_range_by_category CASCADE;
DROP VIEW IF EXISTS country_range_totals CASCADE;

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
