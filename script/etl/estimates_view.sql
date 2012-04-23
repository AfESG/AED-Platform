drop view estimates;

create or replace view estimates as

select
  'GT'||survey_ground_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  actually_seen,
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
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  actually_seen,
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
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  null,
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
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  null,
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
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  null,
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
  completion_year,
  population_estimate,
  population_variance,
  population_confidence_interval,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN ROUND(population_estimate-population_confidence_interval)
    ELSE 0
  END cl95,
  null,
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
  completion_year,
  population_estimate,
  null,
  null,
  null,
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
  completion_year,
  population_estimate_min,
  null,
  null,
  null,
  null,
  'E' category
from survey_others
  join population_submissions on population_submissions.id=population_submission_id
;
