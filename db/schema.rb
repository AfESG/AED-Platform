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

ActiveRecord::Schema.define(:version => 20120223190436) do

  create_table "countries", :force => true do |t|
    t.string   "iso_code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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

# Could not dump table "ft_surveydata" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "geometry_columns", :id => false, :force => true do |t|
    t.string  "f_table_catalog",   :limit => 256, :null => false
    t.string  "f_table_schema",    :limit => 256, :null => false
    t.string  "f_table_name",      :limit => 256, :null => false
    t.string  "f_geometry_column", :limit => 256, :null => false
    t.integer "coord_dimension",                  :null => false
    t.integer "srid",                             :null => false
    t.string  "type",              :limit => 30,  :null => false
  end

  create_table "population_submission_attachments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "population_submission_id"
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

# Could not dump table "range" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

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
    t.string   "species_id"
    t.string   "country_id"
    t.string   "phenotype"
    t.string   "phenotype_basis"
    t.string   "data_type"
    t.boolean  "right_to_grant_permission"
    t.string   "permission_email"
    t.boolean  "mike_site"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.float    "population_confidence_limits"
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
    t.float    "population_confidence_limits"
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
    t.float    "population_confidence_limits"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "asymmetric_upper_confidence_limit"
    t.integer  "asymmetric_lower_confidence_limit"
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
    t.float    "dung_decay_rate_confidence_limits"
    t.boolean  "dung_decay_rate_no_precision_estimate_available"
    t.boolean  "defecation_rate_measured_on_site"
    t.integer  "defecation_rate_estimate_used"
    t.string   "defecation_rate_measurement_site"
    t.string   "defecation_rate_reference"
    t.float    "defecation_rate_variance"
    t.float    "defecation_rate_standard_error"
    t.float    "defecation_rate_t"
    t.integer  "defecation_rate_degrees_of_freedom"
    t.float    "defecation_rate_confidence_limits"
    t.boolean  "defecation_rate_no_precision_estimate_available"
    t.integer  "dung_density_estimate"
    t.float    "dung_density_variance"
    t.float    "dung_density_standard_error"
    t.float    "dung_density_t"
    t.integer  "dung_density_degrees_of_freedom"
    t.float    "dung_density_confidence_limits"
    t.boolean  "dung_density_no_precision_estimate_available"
    t.integer  "dung_encounter_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "individual_transect_length"
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
    t.float    "population_confidence_limits"
    t.boolean  "population_no_precision_estimate_available"
    t.string   "method_of_analysis"
    t.string   "area_calculation_method"
    t.integer  "genotypes_identified"
    t.integer  "samples_analyzed"
    t.integer  "sampling_locations"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.float    "population_confidence_limits"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "person_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "individual_transect_length"
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
    t.float    "population_confidence_limits"
    t.boolean  "population_no_precision_estimate_available"
    t.integer  "transects_covered"
    t.integer  "transects_covered_total_length"
    t.integer  "person_hours"
    t.float    "strip_width"
    t.integer  "observations"
    t.integer  "actually_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "survey_others", :force => true do |t|
    t.integer  "population_submission_id"
    t.string   "other_method_description"
    t.integer  "population_estimate_min"
    t.integer  "population_estimate_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "surveydata" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
