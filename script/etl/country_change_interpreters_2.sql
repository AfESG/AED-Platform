-- Country change interpeters (part 2)

drop view if exists i_dpps_sums_country_reason cascade;
create or replace view i_dpps_sums_country_reason as
select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(speculative)) speculative
from estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
  where e.category='A'
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  CASE WHEN SUM(actually_seen) > (SUM(e.population_estimate)-SQRT(SUM(population_variance))*1.96)
  THEN SUM(actually_seen)
  ELSE ROUND(SUM(e.population_estimate) - SQRT(SUM(population_variance))*1.96)
  END definite,
  round(sqrt(sum(population_variance))*1.96) probable,
  round(sqrt(sum(population_variance))*1.96) possible,
  round(sum(speculative)) speculative
from estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
  where e.category='B'
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  round(sum(definite)) definite,
  round(sum(probable)-sum(definite)) probable,
  round(sqrt(sum(population_variance))*1.96) possible,
  round(sum(speculative)) speculative
from estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
  where e.category='C'
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(speculative)) speculative
from estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
  where e.category='D'
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(speculative)) speculative
from estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
  where e.category='E'
group by
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.country,
  e.reason_change

order by
  analysis_name,
  analysis_year,
  continent,
  region,
  country,
  reason_change
;

--- Statify the pooled base query; it's too slow to run in realtime
drop view if exists dpps_sums_country_reason cascade;
drop table if exists dpps_sums_country_reason cascade;
create table dpps_sums_country_reason as select * from i_dpps_sums_country_reason;

drop view fractional_causes_of_change_by_country_2;
create view fractional_causes_of_change_by_country_2 as
select
  g.analysis_name,
  g.analysis_year,
  g.country,
  "CauseofChange",
  sum(definite) as definite,
  sum(probable) as probable,
  sum(possible) as possible,
  sum(speculative) as specul
from dpps_sums_country_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.country, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.country, display_order, "CauseofChange";

drop view causes_of_change_by_country_2;
create view causes_of_change_by_country_2 as
select
  analysis_name,
  analysis_year,
  country,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from fractional_causes_of_change_by_country_2;

drop view causes_of_change_sums_by_country_2;
create view causes_of_change_sums_by_country_2 as
select
  analysis_name,
  analysis_year,
  country,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  fractional_causes_of_change_by_country_2
group by analysis_name,analysis_year,country;

drop view if exists country_factors_2;
create or replace view country_factors_2 as
select
  c.analysis_name,
  c.analysis_year,
  c.country,
  (actual_dif_def / CASE WHEN definite=0 THEN 1 ELSE definite END) def_factor,
  (actual_dif_prob / CASE WHEN probable=0 THEN 1 ELSE probable END) prob_factor,
  (actual_dif_poss / CASE WHEN possible=0 THEN 1 ELSE possible END) poss_factor,
  (actual_dif_spec / CASE WHEN specul=0 THEN 1 ELSE specul END) spec_factor
from causes_of_change_sums_by_country_2 c
join actual_diff_country a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.country= c.country
;

drop view causes_of_change_by_country_scaled_2;
create view causes_of_change_by_country_scaled_2 as
select
  c.analysis_name,
  c.analysis_year,
  c.country,
  "CauseofChange",
  round(definite * def_factor) definite,
  round(probable * prob_factor) probable,
  round(possible * poss_factor) possible,
  round(specul * spec_factor) specul
from fractional_causes_of_change_by_country_2 c
join country_factors_2 a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.country= c.country
;

drop view if exists causes_of_change_sums_by_country_scaled_2;
create or replace view causes_of_change_sums_by_country_scaled_2 as
select
  c.analysis_name,
  c.analysis_year,
  c.country,
  definite * def_factor definite,
  probable * prob_factor probable,
  possible * poss_factor possible,
  specul * spec_factor specul
from causes_of_change_sums_by_country_2 c
join country_factors_2 a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.country= c.country
;
