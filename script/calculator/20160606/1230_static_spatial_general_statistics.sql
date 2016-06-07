drop table if exists country_pa;
create table country_pa as
select
  cntryname country,
  cntryarea stated,
  safe_isect(
    ST_SetSRID(geom,4326),
    ST_SetSRID(all_pa_geom,4326)
  ) protected_area
from
  country c,
  (select ST_Union(geometry) all_pa_geom
	from protected_area_geometries
  ) pag
where cntryarea > 0;

drop table if exists country_pa_metrics;
create table country_pa_metrics as
select
  country,
  stated,
  ROUND(ST_Area(protected_area::geography,true)/1000000) protected_area_sqkm,
  ROUND((ST_Area(protected_area::geography,true)/1000000)/stated*100) percent_protected from country_pa
order by country;

drop table if exists country_pa_range;
create table country_pa_range as
select
  country,
  stated,
  safe_isect(
    ST_SetSRID(protected_area,4326),
    ST_SetSRID(all_range_geom,4326)
  ) protected_area_range
from
  country_pa cpa,
  (select ST_Union(geometry) all_range_geom
	from range_geometries
	where range=1
  ) arg;

drop table if exists country_pa_range_metrics;
create table country_pa_range_metrics as
select
  cpr.country,
  cpr.stated,
  ROUND(range_sqkm) range_sqkm,
  ROUND(ST_Area(protected_area_range::geography,true)/1000000) protected_area_range_sqkm,
  ROUND(((ST_Area(protected_area_range::geography,true)/1000000)/range_sqkm)*100) percent_protected_range
from country_pa_range cpr
join (select country, SUM(area_sqkm) range_sqkm from country_range_metrics where range=1 group by country) c on c.country = cpr.country
order by country;
