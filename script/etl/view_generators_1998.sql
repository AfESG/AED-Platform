-- Store preferred display order

drop table if exists aed1998.surveytypes CASCADE;
create table aed1998.surveytypes (surveytype text, display_order integer);
insert into aed1998.surveytypes values ('Aerial or Ground Total Counts',1);
insert into aed1998.surveytypes values ('Direct Sample Counts and Reliable Dung Counts',2);
insert into aed1998.surveytypes values ('Other Dung Counts',3);
insert into aed1998.surveytypes values ('Informed Guesses',4);
insert into aed1998.surveytypes values ('Other Guesses',5);
insert into aed1998.surveytypes values ('Unassessed Range',6);


-- Summary totals

create or replace view aed1998.summary_totals_by_continent as
select
  'Africa'::text "CONTINENT",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed1998."Contingrp"
order by "CATEGORY";

create or replace view aed1998.summary_sums_by_continent as
select
  'Africa'::text "CONTINENT",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed1998."Continent";

create or replace view aed1998.summary_totals_by_region as
select
  "REGION",
  "CATEGORY",
  "SURVEYTYPE",
  ROUND("DEFINITE") "DEFINITE",
  ROUND("PROBABLE") "PROBABLE",
  ROUND("POSSIBLE") "POSSIBLE",
  ROUND("SPECUL") "SPECUL"
from aed1998."Regiongrp"
order by "CATEGORY";

create or replace view aed1998.summary_sums_by_region as
select
  "REGION",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed1998."Regions";

create or replace view aed1998.summary_totals_by_country as
select
  "CCODE" ccode,
  "CATEGORY",
  "SURVEYTYPE",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed1998."Countrygrp"
order by "CATEGORY";

create or replace view aed1998.summary_sums_by_country as
select
  "CCODE" ccode,
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed1998."Country";


-- Totals and Data Quality

create or replace view aed1998.continental_and_regional_totals_and_data_quality as
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
  aed1998."Regions" r,
  (select "RANGEAREA" continental_rangearea from aed1998."Continent") c
order by "REGION";

create or replace view aed1998.continental_and_regional_totals_and_data_quality_sum as
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
  aed1998."Continent" r
order by "CONTINENT";

create or replace view aed1998.country_and_regional_totals_and_data_quality as
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
  (select "RANGEAREA" continental_rangearea from aed1998."Continent") a,
  aed1998."Country" c join
  aed1998."Regions" r on c."REGION"=r."REGION"
order by c."REGION","CNTRYNAME";

create or replace view aed1998.country_and_regional_totals_and_data_quality_sum as
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
  (select "RANGEAREA" continental_rangearea from aed1998."Continent") a,
  aed1998."Regions" c
order by c."REGION";

-- Elephant Estimates by Country

drop view if exists aed1998.elephant_estimates_by_country;
create or replace view aed1998.elephant_estimates_by_country as
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
  aed1998."Surveydata" s
  left join (select "CCODE", "RANGEAREA" country_rangearea from aed1998."Country") a
    on s."CCODE" = a."CCODE"
  where s."SELECTION"=1
order by a."CCODE", survey_zone;
