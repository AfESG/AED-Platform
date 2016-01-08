-- Regional change interpeters

drop view if exists i_dpps_sums_region_category cascade;
create or replace view i_dpps_sums_region_category as
select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.category,
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
  e.category

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.category,
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
  e.category

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.category,
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
  e.category

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.category,
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
  e.category

UNION

select
  e.analysis_name,
  e.analysis_year,
  e.continent,
  e.region,
  e.category,
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
  e.category

order by
  analysis_name,
  analysis_year,
  continent,
  region,
  category
;

--- Statify the pooled base query; it's too slow to run in realtime
drop table if exists dpps_sums_region_category cascade;
create table dpps_sums_region_category as select * from i_dpps_sums_region_category;

drop view if exists dpps_sums_region;
create view dpps_sums_region as
select
  analysis_name,
  analysis_year,
  continent,
  region,
  sum(definite) definite,
  sum(probable) probable,
  sum(possible) possible,
  sum(speculative) speculative
from
  dpps_sums_region_category
group by
  analysis_name,
  analysis_year,
  continent,
  region
order by
  analysis_name,
  analysis_year,
  continent,
  region;

drop view if exists actual_diff_region;
create view actual_diff_region as
select
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.definite-o.definite actual_dif_def,
  a.probable-o.probable actual_dif_prob,
  a.possible-o.possible actual_dif_poss,
  a.speculative-o.speculative actual_dif_spec
from analyses y
  join dpps_sums_region a
    on a.analysis_name=y.analysis_name and a.analysis_year=y.analysis_year
  join dpps_sums_region o
    on o.analysis_name=y.analysis_name and o.analysis_year=y.comparison_year
    and a.region = o.region
order by
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region;

drop view if exists i_dpps_sums_region_category_reason;
create view i_dpps_sums_region_category_reason as
select * from (
  select
    d.analysis_name,
    d.analysis_year,
    continent,
    region,
    d.category,
    reason_change,
    sum(definite) definite,
    sum(probable) probable,
    sum(possible) possible,
    sum(speculative) speculative
  from
    analyses y
    join estimate_locator e
      on e.analysis_name=y.analysis_name and e.analysis_year=y.analysis_year
        and e.reason_change != '-'
    join estimate_dpps d on e.input_zone_id = d.input_zone_id
      and e.analysis_name = d.analysis_name
      and e.analysis_year = d.analysis_year
  group by
    d.analysis_name,
    d.analysis_year,
    continent,
    region,
    d.category,
    reason_change
  union
  select
    analysis_name,
    analysis_year,
    continent,
    region,
    category,
    reason_change,
    sum(-1*definite) definite,
    sum(-1*probable) probable,
    sum(-1*possible) possible,
    sum(-1*speculative) speculative
  from
    (
      select distinct
        d.analysis_name,
        e.analysis_year,
        continent,
        region,
        d.category,
        c.reason_change,
        definite,
        probable,
        possible,
        speculative
      from
        analyses y
        join estimate_locator e
          on e.analysis_name=y.analysis_name and e.analysis_year=y.analysis_year
            and e.reason_change != '-'
        join changed_strata c on e.input_zone_id = c.new_stratum
          and e.analysis_name = c.analysis_name
        join estimate_dpps d on d.input_zone_id = c.replaced_stratum
          and e.analysis_name = d.analysis_name
          and d.analysis_year = y.comparison_year
    ) s
  group by
    analysis_name,
    analysis_year,
    continent,
    region,
    category,
    reason_change
) s
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  category,
  reason_change
;

--- Statify the reason base query; it's too slow to run in realtime
drop table if exists dpps_sums_region_category_reason cascade;
create table dpps_sums_region_category_reason as select * from i_dpps_sums_region_category_reason;

drop view if exists fractional_causes_of_change_by_region;
create view fractional_causes_of_change_by_region as
select
  g.analysis_name,
  g.analysis_year,
  g.region,
  "CauseofChange",
  sum(definite) as definite,
  sum(probable) as probable,
  sum(possible) as possible,
  sum(speculative) as specul
from dpps_sums_region_category_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.region, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.region, display_order, "CauseofChange";

drop view if exists causes_of_change_by_region;
create view causes_of_change_by_region as
select
  analysis_name,
  analysis_year,
  region,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from fractional_causes_of_change_by_region;

drop view if exists causes_of_change_sums_by_region;
create view causes_of_change_sums_by_region as
select
  analysis_name,
  analysis_year,
  region,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  fractional_causes_of_change_by_region
group by analysis_name,analysis_year,region;

drop view if exists region_factors;
create or replace view region_factors as
select
  c.analysis_name,
  c.analysis_year,
  c.region,
  (actual_dif_def / CASE WHEN definite=0 THEN 1 ELSE definite END) def_factor,
  (actual_dif_prob / CASE WHEN probable=0 THEN 1 ELSE probable END) prob_factor,
  (actual_dif_poss / CASE WHEN possible=0 THEN 1 ELSE possible END) poss_factor,
  (actual_dif_spec / CASE WHEN specul=0 THEN 1 ELSE specul END) spec_factor
from causes_of_change_sums_by_region c
join actual_diff_region a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.region = c.region
;

drop view if exists causes_of_change_by_region_scaled;
create view causes_of_change_by_region_scaled as
select
  c.analysis_name,
  c.analysis_year,
  c.region,
  "CauseofChange",
  round(definite * def_factor) definite,
  round(probable * prob_factor) probable,
  round(possible * poss_factor) possible,
  round(specul * spec_factor) specul
from fractional_causes_of_change_by_region c
join region_factors a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.region = c.region
;

drop view if exists causes_of_change_sums_by_region_scaled;
create or replace view causes_of_change_sums_by_region_scaled as
select
  c.analysis_name,
  c.analysis_year,
  c.region,
  definite * def_factor definite,
  probable * prob_factor probable,
  possible * poss_factor possible,
  specul * spec_factor specul
from causes_of_change_sums_by_region c
join region_factors a
  on a.analysis_name = c.analysis_name
  and a.analysis_year = c.analysis_year
  and a.region = c.region
;
