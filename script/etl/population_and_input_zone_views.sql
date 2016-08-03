--- population view
CREATE OR REPLACE VIEW populations AS
  SELECT
    ps.id,
    ps.site_name AS name,
    s.country_id
  FROM population_submissions ps
    JOIN submissions s ON (ps.submission_id = s.id);


-- input zone view
CREATE OR REPLACE VIEW input_zones AS
  WITH iz_data AS (
      SELECT DISTINCT ON (trim(e.replacement_name))
        trim(e.replacement_name) AS name,
        ps.id                    AS population_id
      FROM estimate_factors_analyses_categorized e
        JOIN population_submissions ps ON (e.population_submission_id = ps.id)
      ORDER BY trim(e.replacement_name)

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
