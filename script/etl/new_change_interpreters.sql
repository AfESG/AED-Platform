-- Dissected from/to information

drop view if exists changed_strata cascade;
create or replace view changed_strata as
select distinct
  analysis_name,
  reason_change,
  replaced_stratum,
  new_stratum
from (
  select
    q.analysis_name,
    CAST(CASE
      WHEN q.reason_change = '-' and a.age > 10 THEN 'DD'
      ELSE q.reason_change
    END AS varchar(255)) reason_change,
    q.replaced_stratum,
    q.new_stratum
    from (
      select distinct
        changes.analysis_name,
        changes.reason_change,
        unnest(regexp_split_to_array(changes.new_strata::text, ','::text)) AS new_stratum,
        unnest(regexp_split_to_array(changes.replaced_strata::text, ','::text)) AS replaced_stratum
      from changes
    ) q
  left join estimate_factors_analyses a
    on replaced_stratum = a.input_zone_id and q.analysis_name = a.analysis_name
  where
    q.new_stratum IS NOT NULL AND q.new_stratum != ''::text
  order by
    q.analysis_name,
    q.reason_change,
    q.replaced_stratum,
    q.new_stratum
) w
where w.reason_change != '-';

