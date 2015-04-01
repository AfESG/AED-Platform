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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150401012229) do

  create_table "analyses", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "comparison_year"
    t.integer "analysis_year"
  end

  create_table "changes", :force => true do |t|
    t.string   "analysis_name"
    t.integer  "analysis_year"
    t.string   "replacement_name"
    t.string   "replaced_strata"
    t.string   "new_strata"
    t.string   "reason_change"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "country"
  end

  create_table "continents", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "iso_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
  end

  create_table "country_range_metrics", :id => false, :force => true do |t|
    t.text    "continent"
    t.string  "region",        :limit => 20
    t.string  "country",       :limit => 50
    t.decimal "range",                       :precision => 10, :scale => 0
    t.string  "range_quality", :limit => 10
    t.float   "area_sqkm"
  end

  create_table "data_request_forms", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "department"
    t.string   "organization"
    t.string   "telephone"
    t.string   "fax"
    t.string   "email"
    t.string   "website"
    t.text     "address"
    t.string   "town"
    t.string   "post_code"
    t.string   "state"
    t.string   "country"
    t.text     "extracts"
    t.text     "research"
    t.text     "subset_other"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dpps_sums_continent_category", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_continent_category_reason", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.text    "category"
    t.string  "reason_change"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_country_category", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.string  "region"
    t.string  "country"
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_country_category_reason", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.string  "region"
    t.string  "country"
    t.text    "category"
    t.string  "reason_change"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_region_category", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.string  "region"
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_region_category_reason", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "continent"
    t.string  "region"
    t.text    "category"
    t.string  "reason_change"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "mike_sites", :force => true do |t|
    t.integer  "country_id"
    t.string   "subregion"
    t.string   "site_code"
    t.text     "site_name"
    t.integer  "area"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "population_submission_attachments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "population_submission_id"
    t.text     "attachment_type"
    t.boolean  "restrict"
  end

  create_table "population_submissions", :force => true do |t|
    t.integer  "submission_id"
    t.string   "data_licensing"
    t.date     "embargo_date"
    t.string   "site_name"
    t.string   "designate"
    t.integer  "area"
    t.integer  "completion_year"
    t.integer  "completion_month"
    t.string   "season"
    t.string   "survey_type"
    t.string   "survey_type_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "abstract"
    t.text     "link"
    t.text     "citation"
    t.boolean  "submitted"
    t.boolean  "released"
    t.string   "short_citation"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "range_discrepancies", :id => false, :force => true do |t|
    t.integer "gid"
    t.integer "actual"
    t.float   "calculated"
    t.integer "range",      :limit => 2
    t.string  "rangequali", :limit => 10
    t.text    "centroid"
  end

  create_table "regions", :force => true do |t|
    t.integer  "continent_id"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "replacement_map", :id => false, :force => true do |t|
    t.text    "mike_site"
    t.text    "aed2007_oids"
    t.text    "current_strata"
    t.text    "reason_change"
    t.integer "id",             :null => false
  end

  create_table "report_narratives", :force => true do |t|
    t.string   "uri"
    t.text     "narrative"
    t.text     "footnote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spatial_ref_sys", :id => false, :force => true do |t|
    t.integer "srid",                      :null => false
    t.string  "auth_name", :limit => 256
    t.integer "auth_srid"
    t.string  "srtext",    :limit => 2048
    t.string  "proj4text", :limit => 2048
  end

  create_table "species", :force => true do |t|
    t.string   "scientific_name"
    t.string   "common_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "species_range_state_countries", :force => true do |t|
    t.integer  "species_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", :force => true do |t|
    t.integer  "user_id"
    t.string   "phenotype"
    t.string   "phenotype_basis"
    t.string   "data_type"
    t.boolean  "right_to_grant_permission"
    t.string   "permission_email"
    t.boolean  "is_mike_site"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "species_id"
    t.integer  "country_id"
    t.integer  "mike_site_id"
  end

  create_table "survey_aerial_sample_count_strata", :force => true do |t|
    t.integer  "survey_aerial_sample_count_id"
    t.string   "stratum_name"
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

  create_table "survey_aerial_sample_counts", :force => true do |t|
    t.integer  "population_submission_id"
    t.integer  "total_possible_transects"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_aerial_total_count_strata", :force => true do |t|
    t.integer  "survey_aerial_total_count_id"
    t.string   "stratum_name"
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "average_speed"
    t.integer  "average_transect_spacing"
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

  create_table "survey_aerial_total_counts", :force => true do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_dung_count_line_transect_strata", :force => true do |t|
    t.integer  "survey_dung_count_line_transect_id"
    t.string   "stratum_name"
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
    t.string   "observations_distance_method"
    t.integer  "actually_seen"
    t.integer  "dung_piles"
    t.string   "dung_decay_rate_measurement_method"
    t.integer  "dung_decay_rate_estimate_used"
    t.string   "dung_decay_rate_measurement_site"
    t.integer  "dung_decay_rate_measurement_year"
    t.string   "dung_decay_rate_reference"
    t.float    "dung_decay_rate_variance"
    t.float    "dung_decay_rate_standard_error"
    t.float    "dung_decay_rate_t"
    t.integer  "dung_decay_rate_degrees_of_freedom"
    t.float    "dung_decay_rate_confidence_interval"
    t.boolean  "dung_decay_rate_no_precision_estimate_available"
    t.boolean  "defecation_rate_measured_on_site"
    t.integer  "defecation_rate_estimate_used"
    t.string   "defecation_rate_measurement_site"
    t.string   "defecation_rate_reference"
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

  create_table "survey_dung_count_line_transects", :force => true do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_faecal_dna_strata", :force => true do |t|
    t.integer  "survey_faecal_dna_id"
    t.string   "stratum_name"
    t.integer  "stratum_area"
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_t"
    t.integer  "population_degrees_of_freedom"
    t.float    "population_confidence_interval"
    t.boolean  "population_no_precision_estimate_available"
    t.string   "method_of_analysis"
    t.string   "area_calculation_method"
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

  create_table "survey_faecal_dnas", :force => true do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_ground_sample_count_strata", :force => true do |t|
    t.integer  "survey_ground_sample_count_id"
    t.string   "stratum_name"
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

  create_table "survey_ground_sample_counts", :force => true do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_ground_total_count_strata", :force => true do |t|
    t.integer  "survey_ground_total_count_id"
    t.string   "stratum_name"
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

  create_table "survey_ground_total_counts", :force => true do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_individual_registrations", :force => true do |t|
    t.integer  "population_submission_id"
    t.integer  "population_estimate"
    t.integer  "population_upper_range"
    t.integer  "monitoring_years"
    t.string   "monitoring_frequency"
    t.string   "fenced_site"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "porous_fenced_site"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "survey_geometry_id"
  end

  create_table "survey_others", :force => true do |t|
    t.integer  "population_submission_id"
    t.string   "other_method_description"
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

  create_table "survey_range_intersection_metrics", :id => false, :force => true do |t|
    t.text    "analysis_name"
    t.integer "analysis_year"
    t.string  "region"
    t.string  "range_quality", :limit => 10
    t.text    "category"
    t.string  "country"
    t.float   "area_sqkm"
  end

  create_table "surveytypes", :id => false, :force => true do |t|
    t.string  "category",      :limit => 8
    t.string  "surveytype"
    t.integer "display_order"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "name"
    t.string   "job_title"
    t.string   "department"
    t.string   "organization"
    t.string   "phone"
    t.string   "fax"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "address_3"
    t.string   "city"
    t.string   "country"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",                              :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
