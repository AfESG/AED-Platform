select setval('submissions_id_seq',3000);
select setval('population_submissions_id_seq',3000);

delete from submissions where id>1000 and id<3000;
insert into submissions (id, user_id, species_id, phenotype, created_at, updated_at, country_id) select "OBJECTID"+1000, 34, 1, 'Unknown', '2007-01-01', '2007-01-01', countries.id from aed2007."Surveydata" s left join countries on countries.name = s."CNTRYNAME";

delete from population_submissions where id>1000 and id<3000;
insert into population_submissions (id,submission_id,site_name,designate,area,completion_year,data_licensing,season,survey_type,short_citation,latitude,longitude) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "DESIGNATE", "AREA_SQKM", "CYEAR", 'CR', "CSEASON", "METHOD", "REFERENCE", "LAT", "LON"  from aed2007."Surveydata";
update population_submissions set survey_type='O' where survey_type='IG' or survey_type='OG';

--- Aerial Total ---
---
select setval('survey_aerial_total_counts_id_seq',3000);
delete from survey_aerial_total_counts where id>1000 and id<3000;
insert into survey_aerial_total_counts (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='AT';

select setval('survey_aerial_total_count_strata_id_seq',3000);
delete from survey_aerial_total_count_strata where id>1000 and id<3000;
insert into survey_aerial_total_count_strata (id, survey_aerial_total_count_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95" from aed2007."Surveydata"
  where "METHOD"='AT';

--- Aerial Sample ---
---
select setval('survey_aerial_sample_counts_id_seq',3000);
delete from survey_aerial_sample_counts where id>1000 and id<3000;
insert into survey_aerial_sample_counts (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='AS';

select setval('survey_aerial_sample_count_strata_id_seq',3000);
delete from survey_aerial_sample_count_strata where id>1000 and id<3000;
insert into survey_aerial_sample_count_strata (id, survey_aerial_sample_count_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval, seen_in_transects) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95", "ACTUALSEEN" from aed2007."Surveydata"
  where "METHOD"='AS';

--- Ground Total ---
---
select setval('survey_ground_total_counts_id_seq',3000);
delete from survey_ground_total_counts where id>1000 and id<3000;
insert into survey_ground_total_counts (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='GT';

select setval('survey_ground_total_count_strata_id_seq',3000);
delete from survey_ground_total_count_strata where id>1000 and id<3000;
insert into survey_ground_total_count_strata (id, survey_ground_total_count_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95" from aed2007."Surveydata"
  where "METHOD"='GT';

--- Ground Sample ---
---
select setval('survey_ground_sample_counts_id_seq',3000);
delete from survey_ground_sample_counts where id>1000 and id<3000;
insert into survey_ground_sample_counts (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='GS';

select setval('survey_ground_sample_count_strata_id_seq',3000);
delete from survey_ground_sample_count_strata where id>1000 and id<3000;
insert into survey_ground_sample_count_strata (id, survey_ground_sample_count_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95" from aed2007."Surveydata"
  where "METHOD"='GS';

--- Dung Count ---
---
select setval('survey_dung_count_line_transects_id_seq',3000);
delete from survey_dung_count_line_transects where id>1000 and id<3000;
insert into survey_dung_count_line_transects (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='DC';

select setval('survey_dung_count_line_transect_strata_id_seq',3000);
delete from survey_dung_count_line_transect_strata where id>1000 and id<3000;
insert into survey_dung_count_line_transect_strata (id, survey_dung_count_line_transect_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95" from aed2007."Surveydata"
  where "METHOD"='DC';

--- Genetic Dung Count ---
---
select setval('survey_faecal_dnas_id_seq',3000);
delete from survey_faecal_dnas where id>1000 and id<3000;
insert into survey_faecal_dnas (id,population_submission_id,surveyed_at_stratum_level,stratum_level_data_submitted) select "OBJECTID"+1000, "OBJECTID"+1000, false, false from aed2007."Surveydata" where "METHOD"='GD';

select setval('survey_faecal_dna_strata',3000);
delete from survey_faecal_dna_strata where id>1000 and id<3000;
insert into survey_faecal_dna_strata (id, survey_faecal_dna_id, stratum_name, stratum_area, population_estimate, population_variance, population_standard_error, population_confidence_interval) select "OBJECTID"+1000, "OBJECTID"+1000, "SURVEYZONE", "AREA_SQKM", "ESTIMATE", "VARIANCE", "STDERROR", "CL95" from aed2007."Surveydata"
  where "METHOD"='GD';

--- Individual Registration ---
---
select setval('survey_individual_registrations_id_seq',3000);
delete from survey_individual_registrations where id>1000 and id<3000;
insert into survey_individual_registrations (id,population_submission_id,population_estimate,population_upper_range) select "OBJECTID"+1000, "OBJECTID"+1000, "ESTIMATE", "UPRANGE" from aed2007."Surveydata" where "METHOD"='IR';

--- Other/Guesses ---
---
select setval('survey_others_id_seq',3000);
delete from survey_others where id>1000 and id<3000;
insert into survey_others (id,population_submission_id,population_estimate_min,population_estimate_max,informed) select "OBJECTID"+1000, "OBJECTID"+1000, "ESTIMATE", CASE WHEN "UPRANGE" IS NOT NULL AND "UPRANGE">0 THEN "UPRANGE"+"ESTIMATE" ELSE "ESTIMATE" END,false from aed2007."Surveydata" where "METHOD"='OG';
insert into survey_others (id,population_submission_id,population_estimate_min,population_estimate_max,actually_seen,informed) select "OBJECTID"+1000, "OBJECTID"+1000, "ESTIMATE", CASE WHEN "UPRANGE" IS NOT NULL AND "UPRANGE">0 THEN "UPRANGE"+"ESTIMATE" ELSE "ESTIMATE" END,"ACTUALSEEN",true from aed2007."Surveydata" where "METHOD"='IG';

--- Populate new, official Changes table (you've run migrations, yes?) and make views using it ---
---
delete from changes;
insert into changes (id,analysis_name,analysis_year,replacement_name,replaced_strata,new_strata,reason_change,created_at,updated_at) select r.id, '2012_mike', 2011, r.mike_site, CASE WHEN d."METHOD"='IG' or d."METHOD"='OG' THEN 'O' ELSE d."METHOD" END || (d."OBJECTID"+1000), r.current_strata, r.reason_change, NOW(), NOW() from replacement_map r join aed2007."Surveydata" d on cast(r.aed2007_oids as int)=d."OBJECTID";
update changes set new_strata = replaced_strata where new_strata='';

update survey_aerial_sample_count_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_aerial_total_count_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_dung_count_line_transect_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_faecal_dna_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_ground_sample_count_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_ground_total_count_strata s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_individual_registrations s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;
update survey_others s set survey_geometry_id=g.id
  from survey_geometries g where g.id=s.id-1000 and s.id>=1000 and s.id<=3000;

