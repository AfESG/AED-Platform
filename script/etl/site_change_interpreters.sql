-- Site change interpeters

drop view if exists dpps_sums_site_category cascade;
create view dpps_sums_site_category as
select
  d.analysis_name,
  d.analysis_year,
  continent,
  region,
  replacement_name site,
  d.category,
  sum(definite) definite,
  sum(probable) probable,
  sum(possible) possible,
  sum(speculative) speculative
from
  estimate_locator e
  join estimate_dpps d on e.input_zone_id = d.input_zone_id
    and e.analysis_name = d.analysis_name
    and e.analysis_year = d.analysis_year
group by
  d.analysis_name,
  d.analysis_year,
  continent,
  region,
  site,
  d.category
order by
  d.analysis_name,
  d.analysis_year,
  continent,
  region,
  site,
  d.category;

drop view if exists dpps_sums_site;
create view dpps_sums_site as
select
  analysis_name,
  analysis_year,
  continent,
  region,
  site,
  sum(definite) definite,
  sum(probable) probable,
  sum(possible) possible,
  sum(speculative) speculative
from
  dpps_sums_site_category
group by
  analysis_name,
  analysis_year,
  continent,
  region,
  site
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  site;

drop view if exists actual_diff_site;
create view actual_diff_site as
select
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.site,
  a.definite-o.definite actual_dif_def,
  a.probable-o.probable actual_dif_prob,
  a.possible-o.possible actual_dif_poss,
  a.speculative-o.speculative actual_dif_spec
from analyses y
  join dpps_sums_site a
    on a.analysis_name=y.analysis_name and a.analysis_year=y.analysis_year
  join dpps_sums_site o
    on o.analysis_name=y.analysis_name and o.analysis_year=y.comparison_year
    and a.site = o.site
order by
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.site;

drop view if exists dpps_sums_site_category_reason;
create view dpps_sums_site_category_reason as
select * from (
  select
    d.analysis_name,
    d.analysis_year,
    continent,
    region,
    e.replacement_name site,
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
    site,
    d.category,
    reason_change
  union
  select
    analysis_name,
    analysis_year,
    continent,
    region,
    site,
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
        replacement_name site,
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
    site,
    category,
    reason_change
) s
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  site,
  category,
  reason_change
;

drop view fractional_causes_of_change_by_site;
create view fractional_causes_of_change_by_site as
select
  g.analysis_name,
  g.analysis_year,
  g.site,
  "CauseofChange",
  sum(definite) as definite,
  sum(probable) as probable,
  sum(possible) as possible,
  sum(speculative) as specul
from dpps_sums_site_category_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.site, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.site, display_order, "CauseofChange";

drop view causes_of_change_by_site;
create view causes_of_change_by_site as
select
  analysis_name,
  analysis_year,
  site,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from fractional_causes_of_change_by_site;

drop view causes_of_change_sums_by_site;
create view causes_of_change_sums_by_site as
select
  analysis_name,
  analysis_year,
  site,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  fractional_causes_of_change_by_site
group by analysis_name,analysis_year,site;

