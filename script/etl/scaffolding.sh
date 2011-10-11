rails g scaffold Submission \
  user_id:integer \
  species:string \
  country:string \
  phenotype:string \
  phenotype_basis:string \
  data_type:string \
  right_to_grant_permission:boolean \
  permission_email:string \
  mike_site:boolean

rails g scaffold PopulationSubmission \
  submission_id:integer \
  data_licensing:string \
  embargo_date:date \
  site_name:string \
  designate:string \
  area:integer \
  completion_year:integer \
  completion_month:integer \
  season:string \
  survey_type:string \
  survey_type_other:string

rails g scaffold SurveyAerialTotalCount \
  population_submission_id:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyAerialTotalCountStratum \
  survey_aerial_total_count_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  average_speed:integer \
  average_transect_spacing:integer \
  average_searching_rate:integer \
  transects_covered:integer \
  transects_covered_total_length:integer \
  observations:integer \
  carcasses_fresh:integer \
  carcasses_old:integer \
  carcasses_very_old:integer

rails g scaffold SurveyAerialSampleCount \
  population_submission_id:integer \
  total_possible_transects:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyAerialSampleCountStratum \
  survey_aerial_sample_count_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  sampling_intensity:float \
  transects_covered:integer \
  transects_covered_total_length:integer \
  seen_in_transects:integer \
  seen_outside_transects:integer  
  carcasses_fresh:integer \
  carcasses_old:integer \
  carcasses_very_old:integer

rails g scaffold SurveyGroundTotalCount \
  population_submission_id:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyGroundTotalCountStratum \
  survey_ground_total_count_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  transects_covered:integer \
  transects_covered_total_length:integer \
  person_hours:integer \
  strip_width:float \
  observations:integer \
  actually_seen:integer

rails g scaffold SurveyGroundSampleCount \
  population_submission_id:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyGroundSampleCountStratum \
  survey_ground_sample_count_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  transects_covered:integer \
  transects_covered_total_length:integer \
  person_hours:integer

rails g scaffold SurveyDungCountLineTransect \
  population_submission_id:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyDungCountLineTransectStratum \
  survey_dung_count_line_transect_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  asymmetric_upper_confidence_limit:integer\
  asymmetric_lower_confidence_limit:integer\
  transects_covered:integer \
  transects_covered_total_length:integer \
  strip_width:float \
  observations:integer \
  observations_distance_method:string \
  actually_seen:integer \
  dung_piles:integer \
  dung_decay_rate_measurement_method:string \
  dung_decay_rate_estimate_used:integer \
  dung_decay_rate_measurement_site:string \
  dung_decay_rate_measurement_year:integer \
  dung_decay_rate_reference:string \
  dung_decay_rate_variance:float \
  dung_decay_rate_standard_error:float \
  dung_decay_rate_t:float \
  dung_decay_rate_degrees_of_freedom:integer \
  dung_decay_rate_confidence_limits:float \
  dung_decay_rate_no_precision_estimate_available:boolean \
  \
  defecation_rate_measured_on_site:boolean \
  defecation_rate_estimate_used:integer \
  defecation_rate_measurement_site:string \
  defecation_rate_reference:string \
  defecation_rate_variance:float \
  defecation_rate_standard_error:float \
  defecation_rate_t:float \
  defecation_rate_degrees_of_freedom:integer \
  defecation_rate_confidence_limits:float \
  defecation_rate_no_precision_estimate_available:boolean \
  dung_density_estimate:integer \
  dung_density_variance:float \
  dung_density_standard_error:float \
  dung_density_t:float \
  dung_density_degrees_of_freedom:integer \
  dung_density_confidence_limits:float \
  dung_density_no_precision_estimate_available:boolean \
  dung_encounter_rate:integer

rails g scaffold SurveyFaecalDna \
  population_submission_id:integer \
  surveyed_at_stratum_level:boolean \
  stratum_level_data_submitted:boolean

rails g scaffold SurveyFaecalDnaStratum \
  survey_faecal_dna_id:integer \
  stratum_name:string \
  stratum_area:integer \
  \
  population_estimate:integer \
  population_variance:float \
  population_standard_error:float \
  population_t:float \
  population_degrees_of_freedom:integer \
  population_confidence_limits:float \
  population_no_precision_estimate_available:boolean \
  \
  method_of_analysis:string \
  area_calculation_method:string \
  genotypes_identified:integer \
  samples_analyzed:integer \
  sampling_locations:integer

rails g scaffold SurveyOther \
  population_submission_id:integer \
  other_method_description:string \
  population_estimate_min:integer \
  population_estimate_max:integer

rails g scaffold SurveyIndividualRegistration \
  population_submission_id:integer \
  population_estimate:integer \
  population_upper_range:integer \
  monitoring_years:integer \
  monitoring_frequency:string \
  fenced_site:boolean
