---
--- estimate_factors
---
--- The purpose of this view is to standardize the factors in the various
--- survey strata or count tables so that common operations involved in
--- pooling can be performed on them.
---
drop view estimate_factors cascade;
create or replace view estimate_factors as
select
  'GT'::text estimate_type,
  'GT'||survey_ground_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  1 quality_level,
  actually_seen,
  survey_geometry_id
  from
    survey_ground_total_count_strata
    join survey_ground_total_counts on survey_ground_total_counts.id=survey_ground_total_count_id
    join population_submissions on population_submissions.id=population_submission_id
union
select
  'DC',
  'DC'||survey_dung_count_line_transect_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  CASE
    WHEN dung_decay_rate_measurement_method != 'Decay rate NOT measured on site' and dung_decay_rate_measurement_site != '' THEN 1
    ELSE 0
  END quality_level,
  actually_seen,
  survey_geometry_id
from
  survey_dung_count_line_transect_strata
  join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'AT',
  'AT'||survey_aerial_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  1 quality_level,
  observations actually_seen,
  survey_geometry_id
from
  survey_aerial_total_count_strata
  join survey_aerial_total_counts on survey_aerial_total_counts.id=survey_aerial_total_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'GS',
  'GS'||survey_ground_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  1 quality_level,
  NULL actually_seen,
  survey_geometry_id
from
  survey_ground_sample_count_strata
  join survey_ground_sample_counts on survey_ground_sample_counts.id=survey_ground_sample_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'AS',
  'AS'||survey_aerial_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  1 quality_level,
  seen_in_transects actually_seen,
  survey_geometry_id
from survey_aerial_sample_count_strata
  join survey_aerial_sample_counts on survey_aerial_sample_counts.id=survey_aerial_sample_count_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'GD',
  'GD'||survey_faecal_dna_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_t,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  1 quality_level,
  genotypes_identified actually_seen,
  survey_geometry_id
from survey_faecal_dna_strata
  join survey_faecal_dnas on survey_faecal_dnas.id=survey_faecal_dna_id
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'IR',
  'IR'||survey_individual_registrations.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  citation,
  short_citation,
  population_estimate,
  NULL population_variance,
  NULL population_standard_error,
  NULL population_confidence_interval,
  NULL population_t,
  NULL population_lower_confidence_limit,
  population_upper_range population_upper_confidence_limit,
  CASE
    WHEN population_upper_range is null THEN 1
    ELSE 0
  END quality_level,
  population_estimate actually_seen,
  survey_geometry_id
from survey_individual_registrations
  join population_submissions on population_submissions.id=population_submission_id
union
select
  'O',
  'O'||survey_others.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  citation,
  short_citation,
  CASE
    WHEN informed=false THEN
      (population_estimate_min+population_estimate_max)/2
    ELSE
      population_estimate_min
  END,
  NULL population_variance,
  NULL population_standard_error,
  NULL population_confidence_interval,
  NULL population_t,
  population_estimate_min lower_confidence_limit,
  population_estimate_max population_upper_confidence_limit,
  CASE
    WHEN informed=true THEN 1
    ELSE 0
  END quality_level,
  actually_seen,
  survey_geometry_id
from survey_others
  join population_submissions on population_submissions.id=population_submission_id
;

---
--- estimate_factors_confidence
---
--- This view calculates population_variance or population_confidence_interval
--- if they are missing
---
drop view if exists estimate_factors_confidence;
create view estimate_factors_confidence as
select
  estimate_type,
  input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  citation,
  short_citation,
  quality_level,
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
  CASE
    WHEN population_confidence_interval IS NOT NULL
    THEN population_confidence_interval
    WHEN population_standard_error IS NOT NULL
    THEN population_standard_error * 1.96
    WHEN population_standard_error IS NOT NULL
         AND population_t IS NOT NULL
    THEN population_standard_error * population_t
    WHEN population_variance IS NOT NULL
    THEN SQRT(population_variance) * 1.96
    ELSE null
  END population_confidence_interval,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  CASE WHEN actually_seen IS NULL THEN 0 ELSE actually_seen END actually_seen
  from
    estimate_factors;

---
--- new_strata and replaced_strata
---
--- expand the CSV columns stored in the changes table
---
drop view new_strata cascade;
create view new_strata as
 SELECT q.analysis_name,q.sort_key,q.population,q.replacement_name,q.reason_change,q.new_stratum
   FROM ( SELECT DISTINCT analysis_name, sort_key, population, replacement_name, reason_change, unnest(regexp_split_to_array(changes.new_strata, ','::text)) AS new_stratum
           FROM changes) q
  WHERE q.new_stratum IS NOT NULL AND q.new_stratum <> ''::text
  ORDER BY q.analysis_name, q.sort_key, q.reason_change, q.new_stratum;

drop view replaced_strata cascade;
create view replaced_strata as
 SELECT q.analysis_name,q.sort_key,q.population,q.replacement_name,'-'::text reason_change,q.replaced_stratum
   FROM ( SELECT DISTINCT analysis_name, sort_key, population, replacement_name, unnest(regexp_split_to_array(changes.replaced_strata, ','::text)) AS replaced_stratum
           FROM changes) q
  WHERE q.replaced_stratum IS NOT NULL AND q.replaced_stratum <> ''::text
  ORDER BY q.analysis_name, q.sort_key, q.replaced_stratum;

---
--- estimate_factors_analyses
---
--- Extracts the factors by analysis in context of the target year
---
drop view if exists estimate_factors_analyses;
create view estimate_factors_analyses as
select
  estimate_type,
  input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  a.analysis_name,
  a.analysis_year,
  a.comparison_year,
  a.analysis_year - completion_year age,
  n.sort_key,
  n.population,
  n.replacement_name,
  reason_change,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  quality_level,
  actually_seen
  from
    estimate_factors_confidence
  join new_strata n on n.new_stratum = input_zone_id
  join analyses a on a.analysis_name = n.analysis_name
union
select
  estimate_type,
  input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  a.analysis_name,
  a.comparison_year,
  a.comparison_year,
  a.comparison_year - completion_year age,
  r.sort_key,
  r.population,
  r.replacement_name,
  reason_change,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  quality_level,
  actually_seen
  from
    estimate_factors_confidence
  join replaced_strata r on r.replaced_stratum = input_zone_id
  join analyses a on a.analysis_name = r.analysis_name
;

---
--- estimate_factors_analyses_categorized
---
--- Applies the categorization rules (type, age, confidence).
--- Adds the synthetic LCL95 value used in pooling.
---
drop view if exists estimate_factors_analyses_categorized;
create or replace view estimate_factors_analyses_categorized as
select
  estimate_type,
  input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  analysis_name,
  analysis_year,
  age,
  sort_key,
  population,
  replacement_name,
  CAST(CASE
      WHEN reason_change = '-' and age >= 10 and (comparison_year - completion_year <= 10) AND NOT (estimate_type='O' and (quality_level IS NULL or quality_level != 1)) THEN 'DD'
      ELSE reason_change
  END AS varchar(255)) reason_change,
  citation,
  short_citation,
  population_estimate,
  population_variance,
  population_standard_error,
  population_confidence_interval,
  population_lower_confidence_limit,
  population_upper_confidence_limit,
  quality_level,
  actually_seen,
  CASE
    WHEN population_lower_confidence_limit IS NOT NULL
      THEN population_lower_confidence_limit
    WHEN population_confidence_interval<population_estimate
      THEN population_estimate-population_confidence_interval
    ELSE 0
  END lcl95,
  CASE

    /* old surveys always 'E' */

    WHEN age>=10 THEN 'E'

    /*  dung counts */

    WHEN estimate_type='DC' THEN
      CASE
        WHEN quality_level=1 THEN 'B'
        WHEN (population_variance IS NULL and population_standard_error IS NULL) THEN 'D'
        ELSE 'C'
      END

    WHEN estimate_type='GD' AND analysis_year>2007 THEN 'A'
    WHEN estimate_type='GD' AND analysis_year<=2007 THEN 'C'

    /* totals */

    WHEN (estimate_type='AT' or estimate_type='GT') THEN 'A'

    /* samples */

    WHEN (estimate_type='AS' or estimate_type='GS') THEN
      CASE WHEN population_variance IS NOT NULL THEN 'B' ELSE 'D' END

    /* individual registrations */

    WHEN estimate_type='IR' THEN
      CASE WHEN quality_level = 1 THEN 'A' ELSE 'D' END

    /*  others */

    WHEN estimate_type='O' THEN
      CASE WHEN quality_level = 1 THEN 'D' ELSE 'E' END

    /* a meaningless value 'F' for anything that fell through */

    ELSE 'F'

  END category
  from
    estimate_factors_analyses
;

drop view if exists estimate_locator;
create or replace view estimate_locator as
select
  e.*,
  countries.name country,
  regions.name region,
  continents.name continent
from estimate_factors_analyses_categorized e
join population_submissions on population_submission_id=population_submissions.id
join submissions on submission_id=submissions.id
join countries on country_id=countries.id
join regions on region_id=regions.id
join continents on continent_id=continents.id
;

---
--- estimate_dpps
---
--- Row-level DPPS is useful for consistency check only
---
drop view if exists estimate_dpps;
create or replace view estimate_dpps as
select
  analysis_name,
  analysis_year,
  input_zone_id,
  category,
  population_estimate,
  population_estimate as definite,
  0 as probable,
  0 as possible,
  0 as speculative
from
  estimate_factors_analyses_categorized
where
  category='A'
union
select
  analysis_name,
  analysis_year,
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN lcl95>actually_seen THEN lcl95
    ELSE actually_seen
  END as definite,
  CASE WHEN lcl95>0 or actually_seen>0 THEN
    population_estimate-(CASE
      WHEN lcl95>actually_seen THEN lcl95
      ELSE actually_seen
    END)
    ELSE population_estimate
  END as probable,
  population_confidence_interval as possible,
  0 as speculative
from
  estimate_factors_analyses_categorized
where
  category='B'
union
select
  analysis_name,
  analysis_year,
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN actually_seen>0 THEN actually_seen
    ELSE 0
  END
  as definite,
  population_estimate as probable,
  CASE WHEN lcl95>0 or actually_seen>0 THEN
    population_estimate-(CASE
      WHEN lcl95>actually_seen THEN lcl95
      ELSE actually_seen
    END)
    ELSE 0
  END as possible,
  0 as speculative
from
  estimate_factors_analyses_categorized
where
  category='C'
union
select
  analysis_name,
  analysis_year,
  input_zone_id,
  category,
  population_estimate,
  CASE
    WHEN actually_seen>0 THEN actually_seen
    ELSE 0
  END
  as definite,
  0 as probable,
  CASE
    WHEN actually_seen>0 THEN
      population_estimate-actually_seen
    ELSE
      population_estimate
  END as possible,
  CASE WHEN lcl95>0 and lcl95!=population_estimate THEN (population_estimate-lcl95)*2
  WHEN population_upper_confidence_limit>0 THEN
    population_upper_confidence_limit-population_estimate
  ELSE 0
  END as speculative
from
  estimate_factors_analyses_categorized
where
  category='D'
union
select
  analysis_name,
  analysis_year,
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
  estimate_factors_analyses_categorized
where
  category='E'
;

create view estimate_locator_with_geometry as
select
  g.id as id,
  l.*,
  g.geometry
from survey_geometries g
  join estimate_factors f
    on f.survey_geometry_id = g.id
  join estimate_locator l
    on l.input_zone_id = f.input_zone_id;
