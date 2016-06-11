DROP VIEW IF EXISTS estimate_locator_with_geometry_add;
CREATE VIEW estimate_locator_with_geometry_add AS
  SELECT
    g.id as id,
    l.*,
    g.geom
  FROM survey_geometries g
  JOIN estimate_factors f
    ON f.survey_geometry_id = g.id
  JOIN estimate_factors_analyses_categorized_for_add l
    ON l.input_zone_id = f.input_zone_id;
