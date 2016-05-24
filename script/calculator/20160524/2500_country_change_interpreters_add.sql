-- Country change interpeters

DROP VIEW IF EXISTS estimate_factors_analyses_reasons_for_add cascade;
CREATE OR REPLACE VIEW estimate_factors_analyses_reasons_for_add AS
  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
    age,
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    sum(e.population_variance) as "POPULATION_VARIANCE",
    0 as "GUESS_MIN",
    0 as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category IN ('H', 'I', 'J', 'K', 'L', 'M', 'N')
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region, age

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
    age,
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'C'
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region, age

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
    age,
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    sum(e.best_estimate) as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE 
    e.category = 'D' OR e.category = 'E'
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region, age

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    e.surveytype AS "SURVEYTYPE",
    input_zone_id,
    age,
    analysis_year,
    analysis_name,
    continent,
    country,
    region,
    0 as "ESTIMATE",
    0 as "POPULATION_VARIANCE",
    sum(e.population_lower_confidence_limit) as "GUESS_MIN",
    sum(e.population_upper_confidence_limit) as "GUESS_MAX"
  FROM
    estimate_factors_analyses_categorized_for_add e
  WHERE
    e.category = 'F' OR e.category = 'G'
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region, age

  ORDER BY "REASON_CHANGE";


drop view if exists changes_expanded CASCADE;
CREATE VIEW changes_expanded AS
  SELECT DISTINCT
    a.analysis_name,
    a.analysis_year,
    ch.reason_change,
    CASE
      WHEN ne."REASON_CHANGE" is null THEN ch.reason_change
      WHEN ne."REASON_CHANGE" = '-' AND ne.age >= 10 THEN 'DD'
      ELSE ne."REASON_CHANGE"
    END adjusted_reason_change,
    ch.country,
    ch.replaced_stratum,
    ch.new_stratum
  FROM (
    SELECT
      nc.analysis_name,
      nc.analysis_year,
      nc.reason_change,
      nc.country,
      rc.replaced_stratum,
      nc.new_stratum
    FROM (
      SELECT 
        id, analysis_name, analysis_year, reason_change, country,
        trim(unnest(regexp_split_to_array(new_strata, ','))) as new_stratum
      FROM changes
    ) nc
    LEFT JOIN (
      SELECT
        id, analysis_name, analysis_year, reason_change, country,
        new_strata,
        trim(unnest(regexp_split_to_array(replaced_strata, ','))) as replaced_stratum
      FROM changes
    ) rc ON nc.id = rc.id and nc.new_stratum = ANY((regexp_split_to_array(rc.new_strata, ',')))
    UNION
    SELECT
      analysis_name,
      analysis_year,
      reason_change,
      country,
      trim(unnest(regexp_split_to_array(replaced_strata, ','))) as replaced_stratum,
      '-'
    FROM changes
    WHERE
      new_strata = '-' OR new_strata IS NULL
  ) ch
  JOIN analyses a ON a.analysis_name = ch.analysis_name
  LEFT JOIN estimate_factors_analyses_reasons_for_add ne ON ne.analysis_name = ch.analysis_name
    AND ne.analysis_year = a.analysis_year
    AND ne.input_zone_id = ch.new_stratum;

DROP VIEW IF EXISTS ioc_add_replaced CASCADE;
CREATE VIEW ioc_add_replaced AS
  SELECT
    a.analysis_name,
    a.analysis_year,
    old.continent,
    old.region,
    old.country,
    old.reason_change,
    -1*sum(old.estimate) estimate,
    -1*sum(old.population_variance) population_variance,
    -1*sum(old.guess_min) guess_min,
    -1*sum(old.guess_max) guess_max,
    old.input_zone_id
  FROM
    analyses a
  JOIN (
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.country,
      e.input_zone_id,
      c.adjusted_reason_change reason_change,
      e."ESTIMATE" as estimate,
      e."POPULATION_VARIANCE" population_variance,
      e."GUESS_MIN" guess_min,
      e."GUESS_MAX" guess_max
    FROM (
      SELECT DISTINCT
        analysis_name,
        analysis_year,
        replaced_stratum,
        adjusted_reason_change
      FROM changes_expanded
    ) c
    JOIN analyses a ON c.analysis_name = a.analysis_name and c.analysis_year = a.analysis_year
    JOIN estimate_factors_analyses_reasons_for_add e ON e.analysis_name = c.analysis_name
      AND e.analysis_year = a.comparison_year 
      AND e.input_zone_id = c.replaced_stratum
  ) old ON old.analysis_name = a.analysis_name
    AND old.analysis_year = a.comparison_year
  GROUP BY a.analysis_name, a.analysis_year, old.continent, old.region, old.country, old.input_zone_id, old.reason_change;

DROP VIEW IF EXISTS ioc_add_new CASCADE;
CREATE OR REPLACE VIEW ioc_add_new AS
  SELECT
    a.analysis_name,
    a.analysis_year,
    new.continent,
    new.region,
    new.country,
    new.reason_change,
    sum(new.estimate) estimate,
    sum(new.population_variance) population_variance,
    sum(new.guess_min) guess_min,
    sum(new.guess_max) guess_max,
    new.input_zone_id
  FROM
    analyses a
  JOIN (
    SELECT
      e.analysis_name,
      e.analysis_year,
      e.continent,
      e.region,
      e.country,
      e.input_zone_id,
      c.adjusted_reason_change reason_change,
      e."ESTIMATE" as estimate,
      e."POPULATION_VARIANCE" population_variance,
      e."GUESS_MIN" guess_min,
      e."GUESS_MAX" guess_max
    FROM (
      SELECT DISTINCT
        analysis_name,
        analysis_year,
        new_stratum,
        adjusted_reason_change
      FROM changes_expanded
    ) c
    JOIN estimate_factors_analyses_reasons_for_add e ON e.analysis_name = c.analysis_name
      AND e.analysis_year = c.analysis_year 
      AND e.input_zone_id = c.new_stratum
  ) new ON new.analysis_name = a.analysis_name
    AND new.analysis_year = a.analysis_year
  GROUP BY a.analysis_name, a.analysis_year, new.continent, new.region, new.country, new.input_zone_id, new.reason_change;


-- Note: these may not be necessary

drop view if exists i_add_sums_country_reason_raw cascade;
create or replace view i_add_sums_country_reason_raw as
select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  round(sum("ESTIMATE")) estimate,
  round(sum("POPULATION_VARIANCE")) population_variance,
  round(sum("GUESS_MIN")) guess_min,
  round(sum("GUESS_MAX")) guess_max
from estimate_locator e
  join estimate_factors_analyses_reasons_for_add d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change;

--- Statify the pooled base query; it's too slow to run in realtime
drop table if exists add_sums_country_reason_raw cascade;
create table add_sums_country_reason_raw as select * from i_add_sums_country_reason_raw;

drop view if exists add_sums_country cascade;
create view add_sums_country as
select
  analysis_name,
  analysis_year,
  continent,
  region,
  country,
  sum(estimate) estimate,
  1.96*sqrt(sum(population_variance)) confidence,
  sum(guess_min) guess_min,
  sum(guess_max) guess_max
from
  add_sums_country_reason_raw
group by
  analysis_name,
  analysis_year,
  continent,
  region,
  country
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  country;

drop view if exists add_actual_diff_country cascade;
create view add_actual_diff_country as
select
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.country,
  a.estimate-o.estimate actual_estimate,
  a.confidence-o.confidence actual_confidence,
  a.guess_min-o.guess_min actual_guess_min,
  a.guess_max-o.guess_max actual_guess_max
from analyses y
  join add_sums_country a
    on a.analysis_name=y.analysis_name and a.analysis_year=y.analysis_year
  join add_sums_country o
    on o.analysis_name=y.analysis_name and o.analysis_year=y.comparison_year
    and a.country = o.country
order by
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.country;

-- End potentially unnecessary views

drop view if exists i_add_sums_country_category_reason cascade;
create view i_add_sums_country_category_reason as
  SELECT 
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    reason_change,
    sum(estimate) estimate,
    sum(population_variance) population_variance,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max
  FROM (
    SELECT * FROM ioc_add_new
  UNION ALL
    SELECT * FROM ioc_add_replaced
  ) x
  GROUP BY analysis_name, analysis_year, continent, region, country, reason_change
  ORDER BY analysis_name, analysis_year, continent, region, country, reason_change;

--- Statify the reason base query; it's too slow to run in realtime
drop table if exists add_sums_country_category_reason cascade;
create table add_sums_country_category_reason as select * from i_add_sums_country_category_reason;

--- Totals for base query, req'd due to confidence column

drop view if exists i_add_totals_country_category_reason cascade;
create view i_add_totals_country_category_reason as
  SELECT
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    sum(estimate) estimate,
    sum(confidence) confidence,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max
  FROM (
    SELECT
      analysis_name,
      analysis_year,
      continent,
      region,
      country,
      sum(estimate) estimate,
      1.96*sqrt(sum(population_variance)) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_new i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent, region, country
    UNION ALL
    SELECT
      analysis_name,
      analysis_year,
      continent,
      region,
      country,
      sum(estimate) estimate,
      -1.96*sqrt(abs(sum(population_variance))) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_replaced i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent, region, country
  ) x
  GROUP BY analysis_name, analysis_year, continent, region, country
  ORDER BY analysis_name, analysis_year, continent, region, country;

drop table if exists add_totals_country_category_reason cascade;
create table add_totals_country_category_reason as select * from i_add_totals_country_category_reason;

drop view if exists i_add_totals_region_category_reason cascade;
create view i_add_totals_region_category_reason as
  SELECT
    analysis_name,
    analysis_year,
    continent,
    region,
    sum(estimate) estimate,
    sum(confidence) confidence,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max
  FROM (
    SELECT
      analysis_name,
      analysis_year,
      continent,
      region,
      sum(estimate) estimate,
      1.96*sqrt(sum(population_variance)) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_new i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent, region
    UNION ALL
    SELECT
      analysis_name,
      analysis_year,
      continent,
      region,
      sum(estimate) estimate,
      -1.96*sqrt(abs(sum(population_variance))) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_replaced i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent, region
  ) x
  GROUP BY analysis_name, analysis_year, continent, region
  ORDER BY analysis_name, analysis_year, continent, region;

drop table if exists add_totals_region_category_reason cascade;
create table add_totals_region_category_reason as select * from i_add_totals_region_category_reason;

drop view if exists i_add_totals_continent_category_reason cascade;
create view i_add_totals_continent_category_reason as
  SELECT
    analysis_name,
    analysis_year,
    continent,
    sum(estimate) estimate,
    sum(confidence) confidence,
    sum(guess_min) guess_min,
    sum(guess_max) guess_max
  FROM (
    SELECT
      analysis_name,
      analysis_year,
      continent,
      sum(estimate) estimate,
      1.96*sqrt(sum(population_variance)) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_new i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent
    UNION ALL
    SELECT
      analysis_name,
      analysis_year,
      continent,
      sum(estimate) estimate,
      -1.96*sqrt(abs(sum(population_variance))) confidence,
      sum(guess_min) guess_min,
      sum(guess_max) guess_max
    FROM ioc_add_replaced i
    JOIN cause_of_changes c ON i.reason_change = c.code
    GROUP BY analysis_name, analysis_year, continent
  ) x
  GROUP BY analysis_name, analysis_year, continent
  ORDER BY analysis_name, analysis_year, continent;

drop table if exists add_totals_continent_category_reason cascade;
create table add_totals_continent_category_reason as select * from i_add_totals_continent_category_reason;
