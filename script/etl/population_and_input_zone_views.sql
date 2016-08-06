-- input zone view
CREATE OR REPLACE VIEW input_zones AS
  WITH survey_geom AS (
      SELECT
        id                     AS id,
        ST_SetSRID(geom, 4326) AS geom
      FROM survey_geometries
  ), iz_data AS (
      SELECT
        trim(e.replacement_name)                                                  AS name,
        e.analysis_year                                                           AS analysis_year,
        e.analysis_name                                                           AS analysis_name,
        e.population_submission_id                                                AS population_id,
        e.reason_change                                                           AS cause_of_change,
        e.estimate_type                                                           AS survey_type,
        e.category                                                                AS survey_reliability,
        e.completion_year                                                         AS survey_year,
        sum(e.population_estimate)                                                AS population_estimate,
        e.population_confidence_interval                                          AS percent_cl,
        e.population_upper_confidence_limit - e.population_lower_confidence_limit AS backup_percent_cl,
        e.short_citation                                                          AS source,
        NULL                                                                      AS pfs,
        NULL                                                                      AS area,
        NULL                                                                      AS long,
        NULL                                                                      AS lat,
        st_multi(st_collect(sg.geom))                                             AS geom
      FROM estimate_factors_analyses_categorized e
        JOIN estimate_factors ef ON (e.input_zone_id = ef.input_zone_id)
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
        e.analysis_name)
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
