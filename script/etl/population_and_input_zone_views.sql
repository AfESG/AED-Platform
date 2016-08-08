-- input zone view
CREATE OR REPLACE VIEW input_zones AS
  WITH survey_geom AS (
      SELECT
        id                     AS id,
        ST_SetSRID(geom, 4326) AS geom
      FROM survey_geometries
      GROUP BY id
  ), iz_data AS (
      SELECT
        trim(e.replacement_name)                   AS name,
        e.analysis_year                            AS analysis_year,
        e.analysis_name                            AS analysis_name,
        e.population_submission_id                 AS population_id,
        e.reason_change                            AS cause_of_change,
        e.estimate_type                            AS survey_type,
        e.category                                 AS survey_reliability,
        e.completion_year                          AS survey_year,
        sum(e.population_estimate)                 AS population_estimate,
        e.population_confidence_interval           AS percent_cl,
        e.population_lower_confidence_limit        AS guess_min,
        e.population_lower_confidence_limit        AS guess_max,
        e.short_citation                           AS source,
        round(
            log((((ed.definite + ed.probable + 0.001) /
                  (ed.definite + ed.probable + ed.possible + ed.speculative + 0.001)) + 1) /
                (ela.area_sqkm / rrt.range_area))) AS pfs,
        sum(el.stratum_area)                       AS area,
        CASE WHEN ps.longitude < 0
          THEN
            to_char(abs(ps.longitude), '990D9') || 'W'
        WHEN ps.longitude = 0
          THEN
            '0.0'
        ELSE
          to_char(abs(ps.longitude), '990D9') || 'E'
        END                                        AS lon,
        CASE WHEN ps.latitude < 0
          THEN
            to_char(abs(ps.latitude), '990D9') || 'S'
        WHEN ps.latitude = 0
          THEN
            '0.0'
        ELSE
          to_char(abs(ps.latitude), '990D9') || 'N'
        END                                        AS lat,
        st_multi(st_collect(sg.geom))              AS geom
      FROM estimate_factors_analyses_categorized e
        JOIN estimate_factors ef ON (e.input_zone_id = ef.input_zone_id)
        JOIN estimate_locator el ON (e.input_zone_id = el.input_zone_id)
        JOIN estimate_dpps ed ON (e.input_zone_id = ed.input_zone_id)
        JOIN estimate_locator_areas ela ON (e.input_zone_id = ela.input_zone_id)
        JOIN population_submissions ps ON (el.population_submission_id = ps.id)
        JOIN regional_range_table rrt ON (el.country = rrt.country AND
                                          el.analysis_name = rrt.analysis_name AND el.analysis_year = rrt.analysis_year)
        JOIN survey_geom sg ON (ef.survey_geometry_id = sg.id)
      GROUP BY (
        trim(e.replacement_name),
        e.population_submission_id,
        e.reason_change,
        e.estimate_type,
        e.category,
        e.completion_year,
        e.population_confidence_interval,
        e.population_upper_confidence_limit,
        e.population_lower_confidence_limit,
        e.short_citation,
        e.analysis_year,
        e.analysis_name,
        ed.definite,
        ed.probable,
        ed.possible,
        ed.speculative,
        ela.area_sqkm,
        rrt.range_area,
        ps.longitude,
        ps.latitude)
  )
  SELECT
    row_number()
    OVER (
      ORDER BY name ASC) AS id,
    *
  FROM iz_data;


-- input zone years
CREATE OR REPLACE VIEW input_zones_years AS
  WITH year_data AS (
      SELECT
        trim(e.replacement_name) AS name,
        e.analysis_year
      FROM estimate_factors_analyses_categorized e
  )
  SELECT
    iz.id,
    yd.analysis_year
  FROM input_zones iz
    JOIN year_data yd ON (iz.name = yd.name)
  ORDER BY iz.id, yd.analysis_year;


--- population view
CREATE OR REPLACE VIEW populations AS
  SELECT
    ps.id                         AS id,
    ps.site_name                  AS name,
    s.country_id                  AS country_id,
    st_multi(st_collect(iz.geom)) AS geom
  FROM population_submissions ps
    JOIN submissions s ON (ps.submission_id = s.id)
    JOIN input_zones iz ON (iz.population_id = ps.id)
  GROUP BY (ps.id, ps.site_name, s.country_id)
