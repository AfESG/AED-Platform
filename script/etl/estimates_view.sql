drop view estimates cascade;
create or replace view estimates as
select
  'GT'||survey_ground_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  CASE WHEN actually_seen IS NULL THEN 0 ELSE actually_seen END actually_seen,
  CASE
    WHEN completion_year<2002 THEN 'E'
    ELSE 'A'
  END category
  from
    survey_ground_total_count_strata
    join survey_ground_total_counts on survey_ground_total_counts.id=survey_ground_total_count_id
    join population_submissions on population_submissions.id=population_submission_id
union
select
  'DC'||survey_dung_count_line_transect_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  CASE WHEN actually_seen IS NULL THEN 0 ELSE actually_seen END actually_seen,
  CASE
    WHEN completion_year<2002 THEN 'E'
    WHEN dung_decay_rate_measurement_site is not null and dung_decay_rate_measurement_site!='' THEN 'B'
    ELSE 'C'
  END category
from
  survey_dung_count_line_transect_strata
  join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'AT'||survey_aerial_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  0,
  CASE
    WHEN completion_year<2002 THEN 'E'
    ELSE 'A'
  END category
from
  survey_aerial_total_count_strata
  join survey_aerial_total_counts on survey_aerial_total_counts.id=survey_aerial_total_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'GS'||survey_ground_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  0,
  CASE
    WHEN completion_year<2002 THEN 'E'
    WHEN (CASE
        WHEN population_lower_confidence_limit IS NOT NULL
          THEN population_lower_confidence_limit
        WHEN population_confidence_interval<population_estimate
          THEN ROUND(population_estimate-population_confidence_interval)
        ELSE 0
      END)>0 THEN 'B'
    ELSE 'D'
  END category
from
  survey_ground_sample_count_strata
  join survey_ground_sample_counts on survey_ground_sample_counts.id=survey_ground_sample_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'AS'||survey_aerial_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  CASE
    WHEN population_variance IS NOT NULL
    THEN population_variance
    WHEN population_standard_error IS NOT NULL
    THEN population_standard_error ^ 2
    WHEN population_confidence_interval IS NOT NULL
         AND population_t IS NOT NULL
    THEN (population_confidence_interval/population_t) ^ 2
    WHEN population_confidence_interval IS NOT NULL
    THEN (population_confidence_interval/1.96) ^ 2
    ELSE null
  END population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  0,
  CASE
    WHEN completion_year<2002 THEN 'E'
    WHEN (CASE
        WHEN population_lower_confidence_limit IS NOT NULL
          THEN population_lower_confidence_limit
        WHEN population_confidence_interval<population_estimate
          THEN ROUND(population_estimate-population_confidence_interval)
        ELSE 0
      END)>0 THEN 'B'
    ELSE 'D'
  END category
from survey_aerial_sample_count_strata
  join survey_aerial_sample_counts on survey_aerial_sample_counts.id=survey_aerial_sample_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'GD'||survey_faecal_dna_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  0,
  CASE
    WHEN completion_year<2002 THEN 'E'
    ELSE 'C'
  END category
from survey_faecal_dna_strata
  join survey_faecal_dnas on survey_faecal_dnas.id=survey_faecal_dna_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'IR'||survey_individual_registrations.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  population_estimate,
  0,
  0,
  0,
  0,
  population_estimate,
  CASE
    WHEN completion_year<2002 THEN 'E'
    ELSE 'A'
  END category
from survey_individual_registrations
  join population_submissions on population_submissions.id=population_submission_id
union
select 'O'||survey_others.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  population_estimate_min+population_estimate_max/2,
  0,
  0,
  0,
  0,
  0,
  'E' category
from survey_others
  join population_submissions on population_submissions.id=population_submission_id
union
select cast("OBJECTID" as text),
  null,
  "SURVEYZONE",
  "SURVEYZONE",
  "AREA_SQKM",
  "CYEAR",
  "ESTIMATE",
  "VARIANCE",
  "STDERROR",
  "CL95"::int,
  "ESTIMATE"-"CL95"::int,
  "ACTUALSEEN",
  "CATEGORY"
from aed2007."Surveydata"
;

drop view estimate_dpps;
create or replace view estimate_dpps as
select
  input_zone_id,
  category,
  population_estimate,
  population_estimate as definite,
  0 as probable,
  0 as possible,
  0 as speculative
from
  estimates
where
  category='A'
union
select
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN cl95>actually_seen THEN cl95
    ELSE actually_seen
  END as definite,
  CASE WHEN cl95>0 or actually_seen>0 THEN
    population_estimate-(CASE
      WHEN cl95>actually_seen THEN cl95
      ELSE actually_seen
    END)
    ELSE population_estimate
  END as probable,
  CASE WHEN cl95>0 or actually_seen>0 THEN
    population_estimate-(CASE
      WHEN cl95>actually_seen THEN cl95
      ELSE actually_seen
    END)
    ELSE 0
  END as possible,
  0 as speculative
from
  estimates
where
  category='B'
union
select
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN actually_seen>0 THEN actually_seen
    ELSE 0
  END
  as definite,
  population_estimate as probable,
  CASE WHEN cl95>0 or actually_seen>0 THEN
    population_estimate-(CASE
      WHEN cl95>actually_seen THEN cl95
      ELSE actually_seen
    END)
    ELSE 0
  END as possible,
  0 as speculative
from
  estimates
where
  category='C'
union
select
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN actually_seen>0 THEN actually_seen
    ELSE 0
  END
  as definite,
  0 as probable,
  population_estimate as possible,
  CASE WHEN cl95>0 THEN (population_estimate-cl95)*2
  ELSE 0
  END as speculative
from
  estimates
where
  category='D'
union
select
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN actually_seen>0 THEN actually_seen
    ELSE 0
  END
  as definite,
  0 as probable,
  0 as possible,
  population_estimate-actually_seen as speculative
from
  estimates
where
  category='E'
;


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
