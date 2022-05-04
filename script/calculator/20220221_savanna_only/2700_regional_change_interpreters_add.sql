-- Regional change interpeters

-- Standard base views

DROP VIEW IF EXISTS ioc_add_replaced_regions CASCADE;
CREATE VIEW ioc_add_replaced_regions AS
  SELECT
    a.analysis_name,
    a.analysis_year,
    old.continent,
    old.region,
    old.reason_change,
    -1*sum(old.estimate) estimate,
    sum(old.population_variance) population_variance,
    -1*sum(old.guess_min) guess_min,
    -1*sum(old.guess_max) guess_max
  FROM
    analyses a
  JOIN (
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.phenotype,
      e.phenotype_basis,
      e.reason_change,
      sum(e.population_estimate) estimate,
      sum(e.population_variance) population_variance,
      sum(e.population_lower_confidence_limit) guess_min,
      sum(e.population_upper_confidence_limit) guess_max
    FROM ioc_add_replaced_base e
    WHERE category <> 'C'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
    UNION
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.phenotype,
      e.phenotype_basis,
      e.reason_change,
      sum(e.population_estimate) estimate,
      0 AS population_variance,
      sum(e.population_lower_confidence_limit) + 1.96*sqrt(sum(e.population_variance)) AS guess_min,
      sum(e.population_upper_confidence_limit) + 1.96*sqrt(sum(e.population_variance)) AS guess_max
    FROM ioc_add_replaced_base e
    WHERE category = 'C'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
  ) old ON old.analysis_name = a.analysis_name
    AND old.analysis_year = a.comparison_year
  GROUP BY a.analysis_name, a.analysis_year, old.continent, old.region, old.reason_change;

DROP VIEW IF EXISTS ioc_add_new_regions CASCADE;
CREATE OR REPLACE VIEW ioc_add_new_regions AS
  SELECT
    a.analysis_name,
    a.analysis_year,
    new.continent,
    new.region,
    new.reason_change,
    sum(new.estimate) estimate,
    sum(new.population_variance) population_variance,
    sum(new.guess_min) guess_min,
    sum(new.guess_max) guess_max
  FROM
    analyses a
  JOIN (
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.phenotype,
      e.phenotype_basis,
      e.reason_change,
      sum(e.population_estimate) estimate,
      sum(e.population_variance) population_variance,
      sum(e.population_lower_confidence_limit) guess_min,
      sum(e.population_upper_confidence_limit) guess_max
    FROM ioc_add_new_base e
    WHERE category <> 'C'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
    UNION
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.phenotype,
      e.phenotype_basis,
      e.reason_change,
      sum(e.population_estimate) estimate,
      0 AS population_variance,
      sum(e.population_lower_confidence_limit) + 1.96*sqrt(sum(e.population_variance)) AS guess_min,
      sum(e.population_upper_confidence_limit) + 1.96*sqrt(sum(e.population_variance)) AS guess_max
    FROM ioc_add_new_base e
    WHERE category = 'C'
    GROUP BY e.analysis_name, e.analysis_year, e.continent, e.region, e.phenotype, e.phenotype_basis, e.reason_change
  ) new ON new.analysis_name = a.analysis_name
    AND new.analysis_year = a.analysis_year
  GROUP BY a.analysis_name, a.analysis_year, new.continent, new.region, new.reason_change;

-- Calculated views

drop view if exists i_add_sums_region_category_reason cascade;
create view i_add_sums_region_category_reason as
  SELECT 
    analysis_name,
    analysis_year,
    continent,
    region,
    reason_change,
    sum(estimate) estimate,
    1.96*sqrt(sum(population_variance)) confidence,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max,
    sum(population_variance) meta_population_variance
  FROM (
    SELECT * FROM ioc_add_new_regions i JOIN cause_of_changes c ON i.reason_change = c.code -- don't need to add new fields as we use * here
  UNION ALL
    SELECT * FROM ioc_add_replaced_regions i JOIN cause_of_changes c ON i.reason_change = c.code -- don't need to add new fields as we use * here
  ) x
  GROUP BY analysis_name, analysis_year, continent, region, reason_change
  ORDER BY analysis_name, analysis_year, continent, region, reason_change;

--- Statify the reason base query; it's too slow to run in realtime
drop table if exists add_sums_region_category_reason cascade;
create table add_sums_region_category_reason as select * from i_add_sums_region_category_reason;

--- Totals for base query, req'd due to confidence column

drop view if exists i_add_totals_region_category_reason cascade;
create view i_add_totals_region_category_reason as
  SELECT
    analysis_name,
    analysis_year,
    continent,
    region,
    sum(estimate) estimate,
    1.96*sqrt(sum(meta_population_variance)) confidence,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max
  FROM add_sums_region_category_reason
  GROUP BY analysis_name, analysis_year, continent, region
  ORDER BY analysis_name, analysis_year, continent, region;

drop table if exists add_totals_region_category_reason cascade;
create table add_totals_region_category_reason as select * from i_add_totals_region_category_reason;

