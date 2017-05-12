-- input zone view
DROP VIEW IF EXISTS input_zones CASCADE;
CREATE MATERIALIZED VIEW input_zones AS
WITH aggregate_data AS (
      SELECT
        trim(e.replacement_name)                                              AS name,
        e.analysis_year                                                       AS analysis_year,
        e.analysis_name                                                       AS analysis_name,
        sum(e.population_estimate)                                            AS estimate,
        sum(e.stratum_area)                                                   AS area,
        sum(e.population_variance)                                            AS pv,
        st_multi(st_collect(ST_SetSRID(sg.geom, 4326)))                       AS geom,

        -- todo:  this bit is producing suspect numbers ...
        least(5, greatest(1,
                          round(log((((sum(ed.definite) + sum(ed.probable) + 0.001) /
                                      (sum(ed.definite) + sum(ed.probable) +
                                       sum(ed.possible) + sum(ed.speculative) + 0.001))
                                     + 1) /
                                    (sum(ela.area_sqkm) / rrt.range_area))))) AS pfs

      FROM
        estimate_locator e
        JOIN estimate_locator_areas ela ON (e.input_zone_id = ela.input_zone_id
                                            AND e.analysis_name = ela.analysis_name
                                            AND e.analysis_year = ela.analysis_year)
        JOIN estimate_factors ef ON (e.input_zone_id = ef.input_zone_id)
        JOIN survey_geometries sg ON (ef.survey_geometry_id = sg.id)
        JOIN estimate_dpps ed ON (e.input_zone_id = ed.input_zone_id
                                  AND e.analysis_name = ed.analysis_name
                                  AND e.analysis_year = ed.analysis_year)
        JOIN regional_range_table rrt ON (e.country = rrt.country
                                          AND e.analysis_name = rrt.analysis_name
                                          AND e.analysis_year = rrt.analysis_year)
      GROUP BY (trim(e.replacement_name), e.analysis_year, e.analysis_name, rrt.range_area)
  ), iz_data AS (
      SELECT DISTINCT ON (trim(e.replacement_name), e.analysis_year, e.analysis_name)
        trim(e.replacement_name)   AS name,
        e.analysis_year            AS analysis_year,
        e.analysis_name            AS analysis_name,
        e.population_submission_id AS population_id,
        CASE WHEN e.reason_change = 'NC'
          THEN
            '-'
        ELSE
          reason_change
        END                        AS cause_of_change,
        e.estimate_type            AS survey_type,
        e.category                 AS survey_reliability,
        e.completion_year          AS survey_year,
        ad.estimate                AS population_estimate,
        CASE WHEN e.population_upper_confidence_limit IS NOT NULL
            and e.population_upper_confidence_limit != 0
          THEN
            CASE WHEN e.estimate_type = 'O'
              THEN
                to_char(e.population_upper_confidence_limit - e.population_estimate, '999,999') || '*'
            ELSE
              to_char(e.population_upper_confidence_limit - e.population_estimate, '999,999')
            END
        WHEN e.population_confidence_interval IS NOT NULL
          THEN
            case when e.population_confidence_interval = 0 and ad.pv is not null
              then to_char(ROUND(round(sqrt(ad.pv) * 1.96)), '999,999')
            else
              to_char(ROUND(e.population_confidence_interval), '999,999')
            end
        ELSE
          NULL
        END as percent_cl,
        /*
        -- used for debugging percent_cl:
        e.population_estimate,
        e.population_lower_confidence_limit,
        e.population_upper_confidence_limit,
        e.population_confidence_interval,
        round(sqrt(ad.pv) * 1.96) as cl95,
        */
        e.short_citation           AS source,
        ad.pfs                     AS pfs,
        ad.area                    AS area,
        CASE WHEN ps.longitude < 0
          THEN
            to_char(abs(ps.longitude), '990D9') || 'W'
        WHEN ps.longitude = 0
          THEN
            '0.0'
        ELSE
          to_char(abs(ps.longitude), '990D9') || 'E'
        END                        AS lon,
        CASE WHEN ps.latitude < 0
          THEN
            to_char(abs(ps.latitude), '990D9') || 'S'
        WHEN ps.latitude = 0
          THEN
            '0.0'
        ELSE
          to_char(abs(ps.latitude), '990D9') || 'N'
        END                        AS lat,
        ad.geom                    AS geom
      FROM estimate_locator e
        JOIN aggregate_data ad ON (trim(e.replacement_name) = ad.name
                                   AND e.analysis_name = ad.analysis_name
                                   AND e.analysis_year = ad.analysis_year)
        JOIN population_submissions ps ON (e.population_submission_id = ps.id)
  )
  SELECT
    row_number()
    OVER (
      ORDER BY name ASC) AS id,
    *
  FROM iz_data;


--- population view
DROP VIEW IF EXISTS populations CASCADE;
CREATE MATERIALIZED VIEW populations AS
  SELECT
    ps.id                         AS id,
    ps.site_name                  AS name,
    s.country_id                  AS country_id,
    st_multi(st_collect(iz.geom)) AS geom
  FROM population_submissions ps
    JOIN submissions s ON (ps.submission_id = s.id)
    JOIN input_zones iz ON (iz.population_id = ps.id)
  GROUP BY (ps.id, ps.site_name, s.country_id);
