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

create or replace view aed2002.elephant_estimates_by_country as
select distinct
  "INPCODE",
  "CCODE" ccode,
  "OBJECTID",
  '-' as "ReasonForChange",
  CASE WHEN "DESIGNATE" IS NULL THEN
    "SURVEYZONE"
  ELSE
    "SURVEYZONE" || ' ' || "DESIGNATE"
  END as survey_zone,
  "METHOD" || "QUALITY" method_and_quality,
  "CATEGORY",
  "CYEAR",
  "ESTIMATE",
  CASE WHEN "METHOD"='IG' THEN
    to_char("UPRANGE",'9999999') || '*'
  ELSE
    to_char(ROUND("CL95"),'9999999')
  END "CL95",
  "REFERENCE",
  '-' as "PFS",
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
from aed2002."Surveydata"
order by "CCODE", survey_zone;
