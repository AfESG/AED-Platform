create or replace view aed2007.actual_dif_def as
select
  aed2007."Country"."CCODE" ccode,
  aed2007."Country"."DEFINITE"-aed2002."Country"."DEFINITE" actual_dif_def
from aed2007."Country" 
join aed2002."Country" on
  aed2007."Country"."CCODE" = aed2002."Country"."CCODE"
;

create or replace view aed2007.actual_dif_prob as
select
  aed2007."Country"."CCODE" ccode,
  aed2007."Country"."PROBABLE"-aed2002."Country"."PROBABLE" actual_dif_prob
from aed2007."Country" 
join aed2002."Country" on
  aed2007."Country"."CCODE" = aed2002."Country"."CCODE"
;

create or replace view aed2007.actual_dif_poss as
select
  aed2007."Country"."CCODE" ccode,
  aed2007."Country"."POSSIBLE"-aed2002."Country"."POSSIBLE" actual_dif_poss
from aed2007."Country" 
join aed2002."Country" on
  aed2007."Country"."CCODE" = aed2002."Country"."CCODE"
;

create or replace view aed2007.actual_dif_spec as
select
  aed2007."Country"."CCODE" ccode,
  aed2007."Country"."SPECUL"-aed2002."Country"."SPECUL" actual_dif_spec
from aed2007."Country" 
join aed2002."Country" on
  aed2007."Country"."CCODE" = aed2002."Country"."CCODE"
;

create or replace view aed2007.def_factor as
select 
  "CCODE" ccode,
  actual_dif_def / CASE WHEN sum(sumofdefinite)=0 THEN 1 ELSE sum(sumofdefinite) END def_factor
from aed2007.changesgrp
join aed2007.actual_dif_def on
  "CCODE"=ccode
group by "CCODE", actual_dif_def;

create or replace view aed2007.prob_factor as
select 
  "CCODE" ccode,
  actual_dif_prob / CASE WHEN sum(sumofprobable)=0 THEN 1 ELSE sum(sumofprobable) END prob_factor
from aed2007.changesgrp
join aed2007.actual_dif_prob on
  "CCODE"=ccode
group by "CCODE", actual_dif_prob;

create or replace view aed2007.poss_factor as
select 
  "CCODE" ccode,
  actual_dif_poss / CASE WHEN sum(sumofpossible)=0 THEN 1 ELSE sum(sumofpossible) END poss_factor
from aed2007.changesgrp
join aed2007.actual_dif_poss on
  "CCODE"=ccode
group by "CCODE", actual_dif_poss;

create or replace view aed2007.spec_factor as
select 
  "CCODE" ccode,
  actual_dif_spec / CASE WHEN sum(sumofspecul)=0 THEN 1 ELSE sum(sumofspecul) END spec_factor
from aed2007.changesgrp
join aed2007.actual_dif_spec on
  "CCODE"=ccode
group by "CCODE", actual_dif_spec;

create or replace view aed2007.causes_of_change_by_country as
select
  "CCODE" ccode,
  "CauseofChange",
  round(def_factor * sum(sumofdefinite)) as definite,
  round(prob_factor * sum(sumofprobable)) as probable,
  round(poss_factor * sum(sumofpossible)) as possible,
  round(spec_factor * sum(sumofspecul)) as specul
from aed2007.changesgrp
join aed2007.def_factor on
  "CCODE"=aed2007.def_factor.ccode
join aed2007.prob_factor on
  "CCODE"=aed2007.prob_factor.ccode
join aed2007.poss_factor on
  "CCODE"=aed2007.poss_factor.ccode
join aed2007.spec_factor on
  "CCODE"=aed2007.spec_factor.ccode
join aed2007."CausesOfChange" on
  "ReasonForChange"="ChangeCODE"
group by "CCODE", "CauseofChange", def_factor, prob_factor, poss_factor, spec_factor
order by "CCODE", "CauseofChange";

create or replace view aed2007.summary_totals_by_country as
select
  "CCODE" ccode,
  "CATEGORY",
  "SURVEYTYPE",
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Countrygrp"
order by "CATEGORY";

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

create or replace view aed2007.summary_sums_by_country as
select
  "CCODE" ccode,
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2007."Country";

create or replace view aed2002.summary_sums_by_country as
select
  "CCODE" ccode,
  "DEFINITE",
  "PROBABLE",
  "POSSIBLE",
  "SPECUL"
from aed2002."Country";

create or replace view aed2007.area_of_range_covered_by_country as
select
  t1.ccode,
  t1.surveytype,
  t1.known,
  t2.possible,
  t3.total
from

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as known from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Known' group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t1

left join

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as possible from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Possible' group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t2

on t1.surveytype = t2.surveytype and t1.ccode = t2.ccode

left join

(select aed2007."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as total from aed2007."SurvRang" join aed2007."Country" on "CNTRYNAME_1"=aed2007."Country"."CNTRYNAME" and "Range"=1 group by aed2007."Country"."CCODE","SURVEYTYPE" order by aed2007."Country"."CCODE","SURVEYTYPE") t3

on t1.surveytype = t3.surveytype and t1.ccode = t3.ccode;

create or replace view aed2007.area_of_range_covered_sum_by_country as
select ccode, sum(known) known, sum(possible) possible, sum(total) total from aed2007.area_of_range_covered_by_country group by ccode order by ccode;

create or replace view aed2007.elephant_estimates_by_country as
select distinct
  "CCODE" ccode,
  "OBJECTID",
  "ReasonForChange",
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
  "PFS",
  ROUND("AREA_SQKM") "AREA_SQKM",
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
from aed2007."Surveydata"
left join aed2007."ChangesTracker" on
  "OBJECTID"="CurrentOID"
order by "CCODE", survey_zone;

create or replace view aed2002.elephant_estimates_by_country as
select distinct
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

### THE BELOW DOES NOT WORK BECAUSE 2002 SurvRang does not exist

create or replace view aed2002.area_of_range_covered_by_country as
select
  t1.ccode,
  t1.surveytype,
  t1.known,
  t2.possible,
  t3.total
from

(select aed2002."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as known from aed2002."SurvRang" join aed2002."Country" on "CNTRYNAME_1"=aed2002."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Known' group by aed2002."Country"."CCODE","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t1

left join

(select aed2002."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as possible from aed2002."SurvRang" join aed2002."Country" on "CNTRYNAME_1"=aed2002."Country"."CNTRYNAME" and "Range"=1 and "RangeQuality"='Possible' group by aed2002."Country"."CCODE","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t2

on t1.surveytype = t2.surveytype and t1.ccode = t2.ccode

left join

(select aed2002."Country"."CCODE" ccode,
CASE WHEN "SURVEYTYPE" is null THEN 'Unassessed Range' ELSE "SURVEYTYPE" END
as surveytype, ROUND(SUM("SurvRang"."Shape_Area")) as total from aed2002."SurvRang" join aed2002."Country" on "CNTRYNAME_1"=aed2002."Country"."CNTRYNAME" and "Range"=1 group by aed2002."Country"."CCODE","SURVEYTYPE" order by aed2002."Country"."CCODE","SURVEYTYPE") t3

on t1.surveytype = t3.surveytype and t1.ccode = t3.ccode;

create or replace view aed2002.area_of_range_covered_sum_by_country as
select ccode, sum(known) known, sum(possible) possible, sum(total) total from aed2002.area_of_range_covered_by_country group by ccode order by ccode;
