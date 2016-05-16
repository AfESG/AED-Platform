-- Country change interpeters

DROP VIEW IF EXISTS estimate_factors_analyses_reasons_for_add cascade;
CREATE OR REPLACE VIEW estimate_factors_analyses_reasons_for_add AS
  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
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
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
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
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    surveytype as "SURVEYTYPE",
    input_zone_id,
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
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region

  UNION

  SELECT
    e.reason_change as "REASON_CHANGE",
    e.surveytype AS "SURVEYTYPE",
    input_zone_id,
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
  GROUP BY "REASON_CHANGE", "SURVEYTYPE", analysis_year, analysis_name, input_zone_id, continent, country, region

  ORDER BY "REASON_CHANGE";


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

drop view if exists i_add_sums_country_category_reason cascade;
create view i_add_sums_country_category_reason as
select * from (
  select
    d.analysis_name,
    d.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.reason_change,
    sum("ESTIMATE") estimate,
    1.96*sqrt(sum(d."POPULATION_VARIANCE")) confidence,
    sum("GUESS_MIN") guess_min,
    sum("GUESS_MAX") guess_max
  from
    analyses y
    join estimate_locator e
      on e.analysis_name=y.analysis_name and e.analysis_year=y.analysis_year
        and e.reason_change != '-'
    join estimate_factors_analyses_reasons_for_add d on e.input_zone_id = d.input_zone_id
      and e.analysis_name = d.analysis_name
      and e.analysis_year = d.analysis_year
  group by
    d.analysis_name,
    d.analysis_year,
    e.continent,
    e.region,
    e.country,
    e.reason_change
  union
  select
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    reason_change,
    sum(-1*estimate) estimate,
    -1.96*sqrt(sum(population_variance)) confidence,
    sum(-1*guess_min) guess_min,
    sum(-1*guess_max) guess_max
  from
    (
      select distinct
        d.analysis_name,
        e.analysis_year,
        e.continent,
        e.region,
        e.country,
        c.reason_change,
        d."ESTIMATE" estimate,
        d."POPULATION_VARIANCE" population_variance,
        d."GUESS_MIN" guess_min,
        d."GUESS_MAX" guess_max
      from
        analyses y
        join estimate_locator e
          on e.analysis_name=y.analysis_name and e.analysis_year=y.analysis_year
            and e.reason_change != '-'
        join changed_strata c on e.input_zone_id = c.new_stratum
          and e.analysis_name = c.analysis_name
        join estimate_factors_analyses_reasons_for_add d on d.input_zone_id = c.replaced_stratum
          and e.analysis_name = d.analysis_name
          and d.analysis_year = y.comparison_year
    ) s
  group by
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
    reason_change
) s
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  country,
  reason_change
;

--- Statify the reason base query; it's too slow to run in realtime
drop table if exists add_sums_country_category_reason cascade;
create table add_sums_country_category_reason as select * from i_add_sums_country_category_reason;


