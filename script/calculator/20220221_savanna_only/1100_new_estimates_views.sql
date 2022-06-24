---
--- estimate_factors
---
--- The purpose of this view is to standardize the factors in the various
--- survey strata or count tables so that common operations involved in
--- pooling can be performed on them.
---
drop view estimate_factors cascade;
create or replace view estimate_factors as
WITH ddr_median AS ( -- get ddr median value (dont' check year)
    SELECT 60.9 AS val -- manual override per stakeholders
--     SELECT PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY sdclts.dung_decay_rate_estimate_used) AS val
--     FROM survey_dung_count_line_transect_strata sdclts
--     JOIN survey_dung_count_line_transects sdclt ON sdclts.survey_dung_count_line_transect_id = sdclt.id
--     JOIN population_submissions ps ON sdclt.population_submission_id = ps.id
--     WHERE sdclts.dung_decay_rate_measurement_method = 'Retrospectively'
)
select
  'GT'::text estimate_type,
  'GT'||survey_ground_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  phenotype,
  phenotype_basis,
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
    join submissions on submissions.id = population_submissions.submission_id
  WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select -- retrospective method with matching year
       'DC' AS estimate_type,
       'DC' || survey_dung_count_line_transect_strata.id AS input_zone_id,
       population_submission_id,
       site_name,
       stratum_name,
       stratum_area,
       completion_year,
       phenotype,
       phenotype_basis,
       citation,
       short_citation,
       population_estimate,
       population_variance,
       population_standard_error,
       population_confidence_interval,
       population_t,
       population_lower_confidence_limit,
       population_upper_confidence_limit,
       1 AS quality_level,
       actually_seen,
       survey_geometry_id
from
    survey_dung_count_line_transect_strata
    join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
    join population_submissions on population_submissions.id=population_submission_id
    join submissions on submissions.id = population_submissions.submission_id
WHERE dung_decay_rate_measurement_method = 'Retrospectively'
  AND dung_decay_rate_measurement_year = population_submissions.completion_year
  AND phenotype IN ('Savanna', 'Savanna with hybrid')
union
select -- higher ddr than median
       'DC' AS estimate_type,
       'DC' || survey_dung_count_line_transect_strata.id AS input_zone_id,
       population_submission_id,
       site_name,
       stratum_name,
       stratum_area,
       completion_year,
       phenotype,
       phenotype_basis,
       citation,
       short_citation,
       population_estimate,
       population_variance,
       population_standard_error,
       population_confidence_interval,
       population_t,
       population_lower_confidence_limit,
       population_upper_confidence_limit,
       1 AS quality_level,
       actually_seen,
       survey_geometry_id
from
    survey_dung_count_line_transect_strata
    join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
    join population_submissions on population_submissions.id=population_submission_id
    join submissions on submissions.id = population_submissions.submission_id
WHERE (dung_decay_rate_measurement_method != 'Retrospectively' OR dung_decay_rate_measurement_year != population_submissions.completion_year)
  AND dung_decay_rate_estimate_used >= (select val from ddr_median)
  AND phenotype IN ('Savanna', 'Savanna with hybrid')
union
select -- lower ddr than median but old population estimate is less than the new calculated one
       'DC' AS estimate_type,
       'DC' || survey_dung_count_line_transect_strata.id AS input_zone_id,
       population_submission_id,
       site_name,
       stratum_name,
       stratum_area,
       completion_year,
       phenotype,
       phenotype_basis,
       citation,
       short_citation,
       population_estimate,
       population_variance,
       population_standard_error,
       population_confidence_interval,
       population_t,
       population_lower_confidence_limit,
       population_upper_confidence_limit,
       1 AS quality_level,
       actually_seen,
       survey_geometry_id
from
    survey_dung_count_line_transect_strata
    join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
    join population_submissions on population_submissions.id=population_submission_id
    join submissions on submissions.id = population_submissions.submission_id
WHERE (dung_decay_rate_measurement_method != 'Retrospectively' OR dung_decay_rate_measurement_year != population_submissions.completion_year)
  AND dung_decay_rate_estimate_used < (select val from ddr_median)
  AND defecation_rate_estimate_used > 0 -- fix divide by zero issues
  AND ROUND( -- area * (dung density / (dung production * median DDR))
                  stratum_area * (dung_density_estimate / (defecation_rate_estimate_used * (select val from ddr_median)))
          )::INT >= population_estimate
union
select -- lower ddr than median (estimate)
       'DC' AS estimate_type,
       'DC' || survey_dung_count_line_transect_strata.id AS input_zone_id,
       population_submission_id,
       site_name,
       stratum_name,
       stratum_area,
       completion_year,
       phenotype,
       phenotype_basis,
       citation,
       short_citation,
       ROUND( -- area * (dung density / (dung production * median DDR))
           stratum_area * (dung_density_estimate / (defecation_rate_estimate_used * (select val from ddr_median)))
       )::INT AS population_estimate,
       population_variance,
       population_standard_error,
       population_confidence_interval,
       population_t,
       population_lower_confidence_limit,
       population_upper_confidence_limit,
       1 AS quality_level,
       actually_seen,
       survey_geometry_id
from
    survey_dung_count_line_transect_strata
    join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
    join population_submissions on population_submissions.id=population_submission_id
    join submissions on submissions.id = population_submissions.submission_id
WHERE (dung_decay_rate_measurement_method != 'Retrospectively' OR dung_decay_rate_measurement_year != population_submissions.completion_year)
  AND dung_decay_rate_estimate_used < (select val from ddr_median)
  AND defecation_rate_estimate_used > 0 -- fix divide by zero issues
  AND phenotype IN ('Savanna', 'Savanna with hybrid')
  AND ROUND( -- area * (dung density / (dung production * median DDR))
                  stratum_area * (dung_density_estimate / (defecation_rate_estimate_used * (select val from ddr_median)))
          )::INT < population_estimate
union
select -- lower ddr than median (guess)
       'DC' AS estimate_type,
       'DC' || survey_dung_count_line_transect_strata.id AS input_zone_id,
       population_submission_id,
       site_name,
       stratum_name,
       stratum_area,
       completion_year,
       phenotype,
       phenotype_basis,
       citation,
       short_citation,
       population_estimate - ROUND( -- population estimate - (area * (dung density / (dung production * median DDR)))
           (stratum_area * (dung_density_estimate / (defecation_rate_estimate_used * (select val from ddr_median))))
       )::INT AS population_estimate,
       population_variance,
       population_standard_error,
       population_confidence_interval,
       population_t,
       population_lower_confidence_limit,
       population_upper_confidence_limit,
       0 AS quality_level,
       actually_seen,
       survey_geometry_id
from
    survey_dung_count_line_transect_strata
    join survey_dung_count_line_transects on survey_dung_count_line_transects.id=survey_dung_count_line_transect_id
    join population_submissions on population_submissions.id=population_submission_id
    join submissions on submissions.id = population_submissions.submission_id
WHERE (dung_decay_rate_measurement_method != 'Retrospectively' OR dung_decay_rate_measurement_year != population_submissions.completion_year)
  AND dung_decay_rate_estimate_used < (select val from ddr_median)
  AND defecation_rate_estimate_used > 0 -- fix divide by zero issues
  AND phenotype IN ('Savanna', 'Savanna with hybrid')
  AND ROUND( -- area * (dung density / (dung production * median DDR))
                  stratum_area * (dung_density_estimate / (defecation_rate_estimate_used * (select val from ddr_median)))
          )::INT < population_estimate
union
select
  'AT',
  'AT'||survey_aerial_total_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  phenotype,
  phenotype_basis,
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
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select
  'GS',
  'GS'||survey_ground_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  phenotype,
  phenotype_basis,
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
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select
  'AS',
  'AS'||survey_aerial_sample_count_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  phenotype,
  phenotype_basis,
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
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select
  'GD',
  'GD'||survey_faecal_dna_strata.id input_zone_id,
  population_submission_id,
  site_name,
  stratum_name,
  stratum_area,
  completion_year,
  phenotype,
  phenotype_basis,
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
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select
  'IR',
  'IR'||survey_individual_registrations.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  phenotype,
  phenotype_basis,
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
    WHEN population_upper_range is null
    THEN 1
    ELSE 0
  END quality_level,
  population_estimate actually_seen,
  survey_geometry_id
from survey_individual_registrations
  join population_submissions on population_submissions.id=population_submission_id
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
union
select
  'O',
  'O'||survey_others.id input_zone_id,
  population_submission_id,
  site_name,
  site_name,
  area,
  completion_year,
  phenotype,
  phenotype_basis,
  citation,
  short_citation,
  population_estimate_min,
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
  join submissions on submissions.id = population_submissions.submission_id
WHERE phenotype IN ('Savanna', 'Savanna with hybrid')
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
  phenotype,
  phenotype_basis,
  citation,
  short_citation,
  quality_level,
  population_estimate,
  CASE
      WHEN (estimate_factors.population_variance IS NOT NULL)
      THEN estimate_factors.population_variance
      WHEN (estimate_factors.population_standard_error IS NOT NULL)
      THEN (estimate_factors.population_standard_error ^ (2)::double precision)
      WHEN ((estimate_factors.population_confidence_interval IS NOT NULL)
       AND (estimate_factors.population_t IS NOT NULL))
      THEN ((estimate_factors.population_confidence_interval / estimate_factors.population_t) ^ (2)::double precision) --TODO this value will change
      WHEN (estimate_factors.population_confidence_interval IS NOT NULL)
      THEN ((estimate_factors.population_confidence_interval / (1.96)::double precision) ^ (2)::double precision) --TODO this value will change
      ELSE NULL::double precision
      END AS population_variance,
  estimate_factors.population_standard_error,
  CASE
      WHEN (estimate_factors.population_confidence_interval IS NOT NULL)
      THEN estimate_factors.population_confidence_interval
      WHEN (estimate_factors.population_standard_error IS NOT NULL)
      THEN (estimate_factors.population_standard_error * (1.96)::double precision) --TODO this value will change
      WHEN ((estimate_factors.population_standard_error IS NOT NULL)
       AND (estimate_factors.population_t IS NOT NULL))
      THEN (estimate_factors.population_standard_error * estimate_factors.population_t)
      WHEN (estimate_factors.population_variance IS NOT NULL)
      THEN (sqrt(estimate_factors.population_variance) * (1.96)::double precision) --TODO this value will change
      ELSE NULL::double precision
      END AS population_confidence_interval,
  estimate_factors.population_lower_confidence_limit,
  estimate_factors.population_upper_confidence_limit,
  CASE
      WHEN (estimate_factors.actually_seen IS NULL) THEN 0
      ELSE estimate_factors.actually_seen
      END AS actually_seen
  from
    estimate_factors
;

---
--- new_strata and replaced_strata
---
--- expand the CSV columns stored in the changes table
---
drop view if exists new_strata cascade;
create view new_strata as
 SELECT q.analysis_name,q.sort_key,q.population,q.replacement_name,q.reason_change,q.new_stratum
   FROM ( SELECT DISTINCT analysis_name, sort_key, population, replacement_name, reason_change, unnest(regexp_split_to_array(changes.new_strata, ','::text)) AS new_stratum
           FROM changes) q
  WHERE q.new_stratum IS NOT NULL AND q.new_stratum <> ''::text
  ORDER BY q.analysis_name, q.sort_key, q.reason_change, q.new_stratum;

drop view if exists replaced_strata cascade;
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
  phenotype,
  phenotype_basis,
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
  phenotype,
  phenotype_basis,
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
  phenotype,
  phenotype_basis,
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
    greatest(population_estimate-(CASE
      WHEN lcl95>actually_seen THEN lcl95
      ELSE actually_seen
    END),0)
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
    greatest(population_estimate-(CASE
      WHEN lcl95>actually_seen THEN lcl95
      ELSE actually_seen
    END),0)
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
      greatest(population_estimate-actually_seen,0)
    ELSE
      population_estimate
  END as possible,
  CASE WHEN lcl95>0 and lcl95!=population_estimate THEN greatest((population_estimate-lcl95)*2, 0)
  WHEN population_upper_confidence_limit>0 THEN
    greatest(population_upper_confidence_limit-population_estimate,0)
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
  greatest(population_estimate-actually_seen,0) as speculative
from
  estimate_factors_analyses_categorized
where
  category='E'
;

create view estimate_locator_with_geometry as
select
  g.id as id,
  l.*,
  g.geom
from survey_geometries g
  join estimate_factors f
    on f.survey_geometry_id = g.id
  join estimate_locator l
    on l.input_zone_id = f.input_zone_id;
