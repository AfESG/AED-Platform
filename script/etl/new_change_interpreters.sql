-- Dissected from/to information

drop view if exists changed_strata cascade;
create view changed_strata as
select
  q.analysis_name,
  q.reason_change,
  q.replaced_stratum,
  q.new_stratum
  from (
    select distinct
      changes.analysis_name,
      changes.reason_change,
      unnest(regexp_split_to_array(changes.new_strata::text, ','::text)) AS new_stratum,
      unnest(regexp_split_to_array(changes.replaced_strata::text, ','::text)) AS replaced_stratum
    from changes) q
where
  q.new_stratum IS NOT NULL AND q.new_stratum != ''::text
  and q.reason_change != '-'
order by
  q.analysis_name,
  q.reason_change,
  q.replaced_stratum,
  q.new_stratum;

-- Country change interpeters

drop view if exists dpps_sums_country_category cascade;
create view dpps_sums_country_category as
select
  d.analysis_name,
  d.analysis_year,
  continent,
  region,
  country,
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
  country,
  d.category
order by
  d.analysis_name,
  d.analysis_year,
  continent,
  region,
  country,
  d.category;

drop view if exists dpps_sums_country;
create view dpps_sums_country as
select
  analysis_name,
  analysis_year,
  continent,
  region,
  country,
  sum(definite) definite,
  sum(probable) probable,
  sum(possible) possible,
  sum(speculative) speculative
from
  dpps_sums_country_category
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

drop view if exists actual_diff_country;
create view actual_diff_country as
select
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.country,
  a.definite-o.definite actual_dif_def,
  a.probable-o.probable actual_dif_prob,
  a.possible-o.possible actual_dif_poss,
  a.speculative-o.speculative actual_dif_spec
from analyses y
  join dpps_sums_country a
    on a.analysis_name=y.analysis_name and a.analysis_year=y.analysis_year
  join dpps_sums_country o
    on o.analysis_name=y.analysis_name and o.analysis_year=y.comparison_year
    and a.country = o.country
order by
  y.analysis_name,
  y.analysis_year,
  a.continent,
  a.region,
  a.country;

drop view if exists dpps_sums_country_category_reason;
create view dpps_sums_country_category_reason as
select * from (
  select
    d.analysis_name,
    d.analysis_year,
    continent,
    region,
    country,
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
    country,
    d.category,
    reason_change
  union
  select
    analysis_name,
    analysis_year,
    continent,
    region,
    country,
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
        country,
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
    country,
    category,
    reason_change
) s
order by
  analysis_name,
  analysis_year,
  continent,
  region,
  country,
  category,
  reason_change
;

drop view fractional_causes_of_change_by_country;
create view fractional_causes_of_change_by_country as
select
  g.analysis_name,
  g.analysis_year,
  g.country,
  "CauseofChange",
  sum(definite) as definite,
  sum(probable) as probable,
  sum(possible) as possible,
  sum(speculative) as specul
from dpps_sums_country_category_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.country, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.country, display_order, "CauseofChange";

drop view causes_of_change_by_country;
create view causes_of_change_by_country as
select
  analysis_name,
  analysis_year,
  country,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from fractional_causes_of_change_by_country;

drop view causes_of_change_sums_by_country;
create view causes_of_change_sums_by_country as
select
  analysis_name,
  analysis_year,
  country,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  fractional_causes_of_change_by_country
group by analysis_name,analysis_year,country;

--- Regional change interpreters ---

drop view fractional_causes_of_change_by_region;
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
from dpps_sums_country_category_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.region, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.region, display_order, "CauseofChange";

drop view causes_of_change_by_region;
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

drop view causes_of_change_sums_by_region;
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

--- Continental change interpreters ---

create view fractional_causes_of_change_by_continent as
select
  g.analysis_name,
  g.analysis_year,
  g.continent,
  "CauseofChange",
  sum(definite) as definite,
  sum(probable) as probable,
  sum(possible) as possible,
  sum(speculative) as specul
from dpps_sums_country_category_reason g
join aed2007."CausesOfChange" on
  reason_change="ChangeCODE"
group by g.analysis_name, g.analysis_year, g.continent, display_order, "CauseofChange"
order by g.analysis_name, g.analysis_year, g.continent, display_order, "CauseofChange";

drop view causes_of_change_by_continent;
create view causes_of_change_by_continent as
select
  analysis_name,
  analysis_year,
  continent,
  "CauseofChange",
  round(definite) definite,
  round(probable) probable,
  round(possible) possible,
  round(specul) specul
from fractional_causes_of_change_by_continent;

drop view causes_of_change_sums_by_continent;
create view causes_of_change_sums_by_continent as
select
  analysis_name,
  analysis_year,
  continent,
  round(sum(definite)) definite,
  round(sum(probable)) probable,
  round(sum(possible)) possible,
  round(sum(specul)) specul
from
  fractional_causes_of_change_by_continent
group by analysis_name,analysis_year,continent;

