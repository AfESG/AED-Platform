# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150821111744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

# Could not dump table "2013rangefinal" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

# Could not dump table "add_range" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'survey_geometry'

  create_table "analyses", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "comparison_year"
    t.integer "analysis_year"
  end

# Could not dump table "backup_range_geometries" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

  create_table "changes", force: :cascade do |t|
    t.string   "analysis_name",    limit: 255
    t.integer  "analysis_year"
    t.string   "replacement_name", limit: 255
    t.string   "replaced_strata",  limit: 255
    t.string   "new_strata",       limit: 255
    t.string   "reason_change",    limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "country",          limit: 255
  end

# Could not dump table "continent" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

  create_table "continents", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso_code",   limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.boolean "is_surveyed"
  end

# Could not dump table "country" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

# Could not dump table "country_range" because of following StandardError
#   Unknown type 'geometry' for column 'range_geometry'

  create_table "country_range_metrics", id: false, force: :cascade do |t|
    t.text    "continent"
    t.string  "region",        limit: 20
    t.string  "country",       limit: 50
    t.decimal "range",                    precision: 10
    t.string  "range_quality", limit: 10
    t.float   "area_sqkm"
  end

  create_table "data_request_forms", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "title",        limit: 255
    t.string   "department",   limit: 255
    t.string   "organization", limit: 255
    t.string   "telephone",    limit: 255
    t.string   "fax",          limit: 255
    t.string   "email",        limit: 255
    t.string   "website",      limit: 255
    t.text     "address"
    t.string   "town",         limit: 255
    t.string   "post_code",    limit: 255
    t.string   "state",        limit: 255
    t.string   "country",      limit: 255
    t.text     "extracts"
    t.text     "research"
    t.text     "subset_other"
    t.string   "status",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dpps_sums_continent_category", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_continent_category_reason", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.text    "category"
    t.string  "reason_change", limit: 255
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_country_category", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.string  "country",       limit: 255
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_country_category_reason", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.string  "country",       limit: 255
    t.text    "category"
    t.string  "reason_change", limit: 255
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_region_category", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_region_category_reason", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.text    "category"
    t.string  "reason_change", limit: 255
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

# Could not dump table "inputzone_2013_africa_final2" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "inputzone_2013_africa_final3" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "inputzone_2013_africa_final4b" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "inputzone_2014analysis3" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "inputzone_geometries2012updatefinal1" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

  create_table "mike_sites", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "subregion",  limit: 255
    t.string   "site_code",  limit: 255
    t.text     "site_name"
    t.integer  "area"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

# Could not dump table "old_survey_geometries" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "peter_repopulated" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "peter_step_2" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "peter_step_3" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'geom'

# Could not dump table "peter_step_3_old" because of following StandardError
#   Unknown type 'geometry' for column 'geom'

  create_table "population_submission_attachments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name",           limit: 255
    t.string   "file_content_type",        limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "population_submission_id"
    t.text     "attachment_type"
    t.boolean  "restrict"
  end

  create_table "population_submissions", force: :cascade do |t|
    t.integer  "submission_id"
    t.string   "data_licensing",    limit: 255
    t.date     "embargo_date"
    t.string   "site_name",         limit: 255
    t.string   "designate",         limit: 255
    t.integer  "area"
    t.integer  "completion_year"
    t.integer  "completion_month"
    t.string   "season",            limit: 255
    t.string   "survey_type",       limit: 255
    t.string   "survey_type_other", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "abstract"
    t.text     "link"
    t.text     "citation"
    t.boolean  "submitted"
    t.boolean  "released"
    t.string   "short_citation",    limit: 255
    t.float    "latitude"
    t.float    "longitude"
  end

# Could not dump table "protected_area_geometries" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

  create_table "range_discrepancies", id: false, force: :cascade do |t|
    t.integer "gid"
    t.integer "actual"
    t.float   "calculated"
    t.integer "range",      limit: 2
    t.string  "rangequali", limit: 10
    t.text    "centroid"
  end

# Could not dump table "range_geometries" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geometry'

# Could not dump table "rangegeometries2012ap" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

# Could not dump table "rangegeometries2012ap2" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

# Could not dump table "rangegeometries2012apfinal1" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

# Could not dump table "region" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'geom'

  create_table "regions", force: :cascade do |t|
    t.integer  "continent_id"
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "replacement_map", force: :cascade do |t|
    t.text "mike_site"
    t.text "aed2007_oids"
    t.text "current_strata"
    t.text "reason_change"
  end

  create_table "report_narratives", force: :cascade do |t|
    t.string   "uri",        limit: 255
    t.text     "narrative"
    t.text     "footnote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "review_range" because of following StandardError
#   Unknown type 'geometry(MultiPolygonZM,4326)' for column 'survey_geometry'

  create_table "spatial_ref_sys", primary_key: "srid", force: :cascade do |t|
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

  create_table "species", force: :cascade do |t|
    t.string   "scientific_name", limit: 255
    t.string   "common_name",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "species_range_state_countries", force: :cascade do |t|
    t.integer  "species_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "st_est_loc_geo_tb" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "static_estimate_factors_with_geometry" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "static_estimate_locator_with_geometry" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "strata_2007_geom_math" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "strata_geom_math" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "strata_new_geom_math" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

  create_table "submissions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "phenotype",                 limit: 255
    t.string   "phenotype_basis",           limit: 255
    t.string   "data_type",                 limit: 255
    t.boolean  "right_to_grant_permission"
    t.string   "permission_email",          limit: 255
    t.boolean  "is_mike_site"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "species_id"
    t.integer  "country_id"
    t.integer  "mike_site_id"
  end

  create_table "survey_aerial_sample_count_strata", force: :cascade do |t|
    t.integer  "survey_aerial_sample_count_id"
    t.string   "stratum_name",                               limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.float    "sampling_intensity"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "seen_in_transects"
    t.integer  "seen_outside_transects"
    t.integer  "carcasses_fresh"
    t.integer  "carcasses_old"
    t.integer  "carcasses_very_old"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "carcasses_age_unknown"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_aerial_sample_counts", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.integer  "total_possible_transects"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_aerial_total_count_strata", force: :cascade do |t|
    t.integer  "survey_aerial_total_count_id"
    t.string   "stratum_name",                               limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "average_speed"
    t.float    "average_transect_spacing"
    t.integer  "average_searching_rate"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "observations"
    t.integer  "carcasses_fresh"
    t.integer  "carcasses_old"
    t.integer  "carcasses_very_old"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "carcasses_age_unknown"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_aerial_total_counts", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_dung_count_line_transect_strata", force: :cascade do |t|
    t.integer  "survey_dung_count_line_transect_id"
    t.string   "stratum_name",                                      limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "population_asymmetric_upper_confidence_interval"
    t.integer  "population_asymmetric_lower_confidence_interval"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.float    "strip_width"
    t.integer  "observations"
    t.string   "observations_distance_method",                      limit: 255
    t.integer  "actually_seen"
    t.integer  "dung_piles"
    t.string   "dung_decay_rate_measurement_method",                limit: 255
    t.integer  "dung_decay_rate_estimate_used"
    t.string   "dung_decay_rate_measurement_site",                  limit: 255
    t.integer  "dung_decay_rate_measurement_year"
    t.string   "dung_decay_rate_reference",                         limit: 255
    t.float    "dung_decay_rate_variance"
    t.float    "dung_decay_rate_standard_error"
    t.float    "dung_decay_rate_t"
    t.integer  "dung_decay_rate_degrees_of_freedom"
    t.float    "dung_decay_rate_confidence_interval"
    t.boolean  "dung_decay_rate_no_precision_estimate_available"
    t.boolean  "defecation_rate_measured_on_site"
    t.integer  "defecation_rate_estimate_used"
    t.string   "defecation_rate_measurement_site",                  limit: 255
    t.string   "defecation_rate_reference",                         limit: 255
    t.float    "defecation_rate_variance"
    t.float    "defecation_rate_standard_error"
    t.float    "defecation_rate_t"
    t.integer  "defecation_rate_degrees_of_freedom"
    t.float    "defecation_rate_confidence_interval"
    t.boolean  "defecation_rate_no_precision_estimate_available"
    t.integer  "dung_density_estimate"
    t.float    "dung_density_variance"
    t.float    "dung_density_standard_error"
    t.float    "dung_density_t"
    t.integer  "dung_density_degrees_of_freedom"
    t.float    "dung_density_confidence_interval"
    t.boolean  "dung_density_no_precision_estimate_available"
    t.integer  "dung_encounter_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "individual_transect_length"
    t.integer  "dung_density_asymmetric_upper_confidence_interval"
    t.integer  "dung_density_asymmetric_lower_confidence_interval"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.float    "dung_decay_rate_lower_confidence_limit"
    t.float    "dung_decay_rate_upper_confidence_limit"
    t.float    "defecation_rate_lower_confidence_limit"
    t.float    "defecation_rate_upper_confidence_limit"
    t.float    "dung_density_lower_confidence_limit"
    t.float    "dung_density_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_dung_count_line_transects", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_faecal_dna_strata", force: :cascade do |t|
    t.integer  "survey_faecal_dna_id"
    t.string   "stratum_name",                               limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.string   "method_of_analysis",                         limit: 255
    t.string   "area_calculation_method",                    limit: 255
    t.integer  "genotypes_identified"
    t.integer  "samples_analyzed"
    t.integer  "sampling_locations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_faecal_dnas", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "survey_geometries" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'

# Could not dump table "survey_geometry_locator_buffered" because of following StandardError
#   Unknown type 'geometry' for column 'survey_geometry'

  create_table "survey_ground_sample_count_strata", force: :cascade do |t|
    t.integer  "survey_ground_sample_count_id"
    t.string   "stratum_name",                               limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "person_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "individual_transect_length"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_ground_sample_counts", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_ground_total_count_strata", force: :cascade do |t|
    t.integer  "survey_ground_total_count_id"
    t.string   "stratum_name",                               limit: 255
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "person_hours"
    t.float    "strip_width"
    t.integer  "observations"
    t.integer  "actually_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_ground_total_counts", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_individual_registrations", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.integer  "population_estimate"
    t.integer  "population_upper_range"
    t.integer  "monitoring_years"
    t.string   "monitoring_frequency",     limit: 255
    t.string   "fenced_site",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "porous_fenced_site",       limit: 255
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_others", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.string   "other_method_description", limit: 255
    t.integer  "population_estimate_min"
    t.integer  "population_estimate_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "actually_seen"
    t.boolean  "informed"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_range_intersection_metrics", id: false, force: :cascade do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "region",        limit: 255
    t.string  "range_quality", limit: 10
    t.text    "category"
    t.string  "country",       limit: 255
    t.float   "area_sqkm"
  end

# Could not dump table "survey_range_intersections" because of following StandardError
#   Unknown type 'geometry' for column 'st_intersection'

  create_table "surveytypes", id: false, force: :cascade do |t|
    t.string  "category",      limit: 8
    t.string  "surveytype",    limit: 255
    t.integer "display_order"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 128, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "name",                   limit: 255
    t.string   "job_title",              limit: 255
    t.string   "department",             limit: 255
    t.string   "organization",           limit: 255
    t.string   "phone",                  limit: 255
    t.string   "fax",                    limit: 255
    t.string   "address_1",              limit: 255
    t.string   "address_2",              limit: 255
    t.string   "address_3",              limit: 255
    t.string   "city",                   limit: 255
    t.string   "country",                limit: 255
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",                           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255, null: false
    t.integer  "item_id",                    null: false
    t.string   "event",          limit: 255, null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.integer  "transaction_id"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

end
