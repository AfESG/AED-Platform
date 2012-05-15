drop view estimate_locator;
create or replace view estimate_locator as
select
  estimates.*,
  countries.name country,
  regions.name region,
  continents.name continent
from estimates
join population_submissions on population_submission_id=population_submissions.id
join submissions on submission_id=submissions.id
join countries on country_id=countries.id
join regions on region_id=regions.id
join continents on continent_id=continents.id

union
select
  estimates.*,
  countries.name country,
  regions.name region,
  continents.name continent
from estimates
join aed2007."Surveydata" d on cast(input_zone_id as int) = "OBJECTID"
join countries on countries.name="CNTRYNAME"
join regions on region_id=regions.id
join continents on continent_id=continents.id
where estimates.population_submission_id is null
;
