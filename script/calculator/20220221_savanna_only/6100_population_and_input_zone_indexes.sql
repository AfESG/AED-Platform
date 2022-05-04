CREATE UNIQUE INDEX populations_pk
  ON populations (id);
CREATE INDEX populations_countries_fk
  ON populations (country_id);
CREATE UNIQUE INDEX input_zones_pk
  ON input_zones (id);
CREATE INDEX input_zones_populations_fk
  ON input_zones (population_id);
