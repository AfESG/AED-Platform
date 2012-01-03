-- Store preferred display order

drop table if exists aed2002.surveytypes CASCADE;
create table aed2002.surveytypes (surveytype text, display_order integer);
insert into aed2002.surveytypes values ('Aerial or Ground Total Counts',1);
insert into aed2002.surveytypes values ('Direct Sample Counts and Reliable Dung Counts',2);
insert into aed2002.surveytypes values ('Other Dung Counts',3);
insert into aed2002.surveytypes values ('Informed Guesses',4);
insert into aed2002.surveytypes values ('Other Guesses',5);
insert into aed2002.surveytypes values ('Unassessed Range',6);


-- Summary totals

create or replace view aed2002.summary_totals_by_continent as
select
  'Africa'::text "CONTINENT",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed2002."Contingrp"
order by "CATEGORY";

create or replace view aed2002.summary_sums_by_continent as
select
  'Africa'::text "CONTINENT",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2002."Continent";

create or replace view aed2002.summary_totals_by_region as
select
  "REGION",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed2002."Regiongrp"
order by "CATEGORY";

create or replace view aed2002.summary_sums_by_region as
select
  "REGION",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2002."Regions";

create or replace view aed2002.summary_totals_by_country as
select
  "CCODE" ccode,
  "CATEGORY",
  "SURVEYTYPE",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2002."Countrygrp"
order by "CATEGORY";

create or replace view aed2002.summary_sums_by_country as
select
  "CCODE" ccode,
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2002."Country";


-- Area of range

create or replace view aed2002.fractional_area_of_range_covered_by_country as
select
  'Africa'::text "CONTINENT",
  t1.ccode,
  t1."REGION",
  t1.surveytype,
  t3.known,
  t2.possible,
  t1.total
from

(select aed2002."Country"."CCODE" ccode, aed2002."Country"."REGION",
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, SUM(s."Shape_Area") as total from aed2002."SurveyedRange" s join aed2002."Country" on s."CNTRYNAME"=aed2002."Country"."CNTRYNAME" and "RANGE"=1 group by aed2002."Country"."CCODE",aed2002."Country"."REGION","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t1

left join

(select aed2002."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, SUM(s."Shape_Area") as possible from aed2002."SurveyedRange" s join aed2002."Country" on s."CNTRYNAME"=aed2002."Country"."CNTRYNAME" and "RANGE"=1 and "RANGEQUALI"='Possible' group by aed2002."Country"."CCODE","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t2

on t1.surveytype = t2.surveytype and t1.ccode = t2.ccode

left join

(select aed2002."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, SUM(s."Shape_Area") as known from aed2002."SurveyedRange" s join aed2002."Country" on s."CNTRYNAME"=aed2002."Country"."CNTRYNAME" and "RANGE"=1 and "RANGEQUALI"='Known' group by aed2002."Country"."CCODE","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t3

on t1.surveytype = t3.surveytype and t1.ccode = t3.ccode;

create or replace view aed2002.area_of_range_covered_by_country as
select
  ccode,
  r.surveytype,
  round(known) known,
  round(possible) possible,
  round(total) total
from aed2002.fractional_area_of_range_covered_by_country r
join aed2002.surveytypes s
  on r.surveytype = s.surveytype
order by s.display_order;

create or replace view aed2002.area_of_range_covered_sum_by_country as
select ccode, round(sum(known)) known, round(sum(possible)) possible, round(sum(total)) total from aed2002.fractional_area_of_range_covered_by_country group by ccode order by ccode;

create or replace view aed2002.area_of_range_covered_by_region as
select
  c."REGION",
  v.surveytype,
  round(sum(v.known)) known,
  round(sum(v.possible)) possible,
  round(sum(v.total)) total
from aed2002."Country" c
join aed2002.fractional_area_of_range_covered_by_country v
  on c."CCODE"=v.ccode
join aed2002.surveytypes s
  on v.surveytype = s.surveytype
group by c."REGION", v.surveytype, s.display_order
order by c."REGION", s.display_order;

create or replace view aed2002.area_of_range_covered_sum_by_region as
select "REGION", round(sum(known)) known, round(sum(possible)) possible, round(sum(total)) total from aed2002.fractional_area_of_range_covered_by_country group by "REGION" order by "REGION";

create or replace view aed2002.area_of_range_covered_by_continent as
select
  "CONTINENT",
  v.surveytype,
  round(sum(v.known)) known,
  round(sum(v.possible)) possible,
  round(sum(v.total)) total
from aed2002.fractional_area_of_range_covered_by_country v
join aed2002.surveytypes s
  on v.surveytype = s.surveytype
group by "CONTINENT", v.surveytype, s.display_order
order by s.display_order;

create or replace view aed2002.area_of_range_covered_sum_by_continent as
select "CONTINENT", round(sum(known)) known, round(sum(possible)) possible, round(sum(total)) total from aed2002.fractional_area_of_range_covered_by_country group by "CONTINENT" order by "CONTINENT";


-- Totals and Data Quality

create or replace view aed2002.continental_and_regional_totals_and_data_quality as
select
  'Africa'::text "CONTINENT",
  "REGION",
  "DEFINITE",
  "POSSIBLE",
  "PROBABLE",
  "SPECUL",
  "RANGEAREA",
  round(("RANGEAREA"::float/continental_rangearea::float)*100) "RANGEPERC",
  round("SURVRANGPERC"*100) "SURVRANGPERC",
  to_char("INFOQUALINDEX",'999999D99') "INFQLTYIDX",
  round(ln(("INFOQUALINDEX"+1)/("RANGEAREA"::float/continental_rangearea::float))) "PFS"
from
  aed2002."Regions" r,
  (select "RANGEAREA" continental_rangearea from aed2002."Continent") c
order by "REGION";

create or replace view aed2002.continental_and_regional_totals_and_data_quality_sum as
select
  'Africa'::text "CONTINENT",
  "DEFINITE",
  "POSSIBLE",
  "PROBABLE",
  "SPECUL",
  "RANGEAREA",
  100 "RANGEPERC",
  round("SURVRANGPERC"*100) "SURVRANGPERC",
  to_char("INFOQUALINDEX",'999999D99') "INFQLTYIDX"
from
  aed2002."Continent" r
order by "CONTINENT";

create or replace view aed2002.country_and_regional_totals_and_data_quality as
select
  c."REGION",
  "CNTRYNAME",
  c."DEFINITE",
  c."POSSIBLE",
  c."PROBABLE",
  c."SPECUL",
  c."RANGEAREA",
  round((c."RANGEAREA"::float/r."RANGEAREA"::float)*100) "RANGEPERC",
  round(c."SURVRANGPERC"*100) "SURVRANGPERC",
  to_char(c."INFOQUALINDEX",'999999D99') "INFQLTYIDX",
  round(log((c."INFOQUALINDEX"::float+1)::float/(c."RANGEAREA"::float/continental_rangearea::float))) "PFS"
from
  (select "RANGEAREA" continental_rangearea from aed2002."Continent") a,
  aed2002."Country" c join
  aed2002."Regions" r on c."REGION"=r."REGION"
order by c."REGION","CNTRYNAME";

create or replace view aed2002.country_and_regional_totals_and_data_quality_sum as
select
  c."REGION",
  c."DEFINITE",
  c."POSSIBLE",
  c."PROBABLE",
  c."SPECUL",
  c."RANGEAREA",
  round((c."RANGEAREA"::float/continental_rangearea::float)*100) "RANGEPERC",
  round(c."SURVRANGPERC"*100) "SURVRANGPERC",
  to_char(c."INFOQUALINDEX",'999999D99') "INFQLTYIDX",
  round(ln((c."INFOQUALINDEX"::float+1)::float/(c."RANGEAREA"::float/continental_rangearea::float))) "PFS"
from
  (select "RANGEAREA" continental_rangearea from aed2002."Continent") a,
  aed2002."Regions" c
order by c."REGION";

-- Elephant Estimates by Country

drop view if exists aed2002.elephant_estimates_by_country;
create or replace view aed2002.elephant_estimates_by_country as
select distinct
  "INPCODE",
  a."CCODE" ccode,
  "OBJECTID",
  '-' "ReasonForChange",
  CASE WHEN "DESIGNATE" IS NULL THEN
    "SURVEYZONE"
  ELSE
    "SURVEYZONE" || ' ' || "DESIGNATE"
  END as survey_zone,
  "METHOD" || "QUALITY" method_and_quality,
  "CATEGORY",
  "CYEAR",
  "ESTIMATE",
  CASE WHEN "CL95" is NULL THEN
    to_char("UPRANGE",'9999999') || '*'
  ELSE
    to_char(ROUND("CL95"),'9999999')
  END "CL95",
  "REFERENCE",
  round(log(("QUALITY"::float+1)::float/("AREA_SQKM"::float/country_rangearea::float))) as "PFS",
  ROUND("AREA_SQKM") "AREA_SQKM",
  "LON" numeric_lon,
  "LAT" numeric_lat,
  CASE WHEN "LON"<0 THEN
    to_char(abs("LON"),'999D9')||'W'
  WHEN "LON"=0 THEN
    '0.0'
  ELSE
    to_char(abs("LON"),'999D9')||'E'
  END "LON",
  CASE WHEN "LAT"<0 THEN
    to_char(abs("LAT"),'990D9')||'S'
  WHEN "LAT"=0 THEN
    '0.0'
  ELSE
    to_char(abs("LAT"),'990D9')||'N'
  END "LAT"
from
  aed2002."Surveydata" s
  left join (select "CCODE", "RANGEAREA" country_rangearea from aed2002."Country") a
    on s."CCODE" = a."CCODE"
  where s."SELECTION"=1
order by a."CCODE", survey_zone;
