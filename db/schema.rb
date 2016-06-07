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

ActiveRecord::Schema.define(version: 20160607160851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "2014_range_map_edit_for_2016", primary_key: "gid", force: :cascade do |t|
    t.integer  "range",      limit: 2
    t.string   "rangequali", limit: 10
    t.string   "ccode",      limit: 2
    t.string   "cntryname",  limit: 30
    t.integer  "area_sqkm"
    t.integer  "refid"
    t.string   "datastatus", limit: 2
    t.string   "comments",   limit: 254
    t.string   "rangetype",  limit: 20
    t.string   "comments_1", limit: 254
    t.string   "adjyear_1",  limit: 20
    t.integer  "sourceyear", limit: 2
    t.string   "publisyear", limit: 20
    t.string   "2016",       limit: 20
    t.string   "comnts2016", limit: 254
    t.string   "ref_2016",   limit: 254
    t.string   "chnges2016", limit: 254
    t.geometry "geom",       limit: {:srid=>0, :type=>"multi_polygon"}
  end

  create_table "2014_rangetypeupdates5_final", primary_key: "gid", force: :cascade do |t|
    t.integer  "range",      limit: 2
    t.string   "rangequali", limit: 10
    t.string   "ccode",      limit: 2
    t.string   "cntryname",  limit: 30
    t.integer  "area_sqkm"
    t.integer  "refid"
    t.string   "call_numbe", limit: 30
    t.integer  "scaledenom"
    t.string   "phenotype",  limit: 50
    t.string   "phtypebasi", limit: 50
    t.integer  "phtyperef"
    t.string   "datastatus", limit: 2
    t.string   "comments",   limit: 254
    t.string   "rangetype",  limit: 20
    t.string   "comments_1", limit: 254
    t.string   "adjyear_1",  limit: 20
    t.integer  "sourceyear", limit: 2
    t.string   "publisyear", limit: 20
    t.geometry "geom",       limit: {:srid=>0, :type=>"multi_polygon"}
  end

  create_table "2016_aed_pa_layer", primary_key: "gid", force: :cascade do |t|
    t.decimal  "__gid",                                                 precision: 10
    t.decimal  "ptacode",                                               precision: 10
    t.string   "ptaname",    limit: 254
    t.string   "ccode",      limit: 254
    t.decimal  "year_est",                                              precision: 10
    t.string   "iucncat",    limit: 254
    t.decimal  "iucncatara",                                            precision: 10
    t.string   "designate",  limit: 254
    t.string   "abvdesig",   limit: 254
    t.decimal  "area_sqkm",                                             precision: 10
    t.decimal  "reported",                                              precision: 10
    t.decimal  "calculated",                                            precision: 10
    t.string   "source",     limit: 254
    t.decimal  "refid",                                                 precision: 10
    t.decimal  "inrange",                                               precision: 10
    t.decimal  "samesurvey",                                            precision: 10
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.decimal  "selection",                                             precision: 10
    t.string   "aed2016dis", limit: 5
    t.geometry "geom",       limit: {:srid=>0, :type=>"multi_polygon"}
  end

  create_table "add_range", id: false, force: :cascade do |t|
    t.string   "site_name",           limit: 255
    t.string   "analysis_name"
    t.integer  "analysis_year"
    t.string   "region",              limit: 255
    t.text     "category"
    t.string   "reason_change",       limit: 255
    t.integer  "population_estimate"
    t.string   "country",             limit: 255
    t.text     "input_zone_id"
    t.geometry "survey_geometry",     limit: {:srid=>4326, :type=>"multi_polygon", :has_z=>true, :has_m=>true}
  end

  create_table "add_sums_continent_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",                limit: 255
    t.string  "reason_change"
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
    t.float   "meta_population_variance"
  end

  create_table "add_sums_country_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",                limit: 255
    t.string  "region",                   limit: 255
    t.string  "country",                  limit: 255
    t.string  "reason_change"
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
    t.float   "meta_population_variance"
  end

  create_table "add_sums_country_reason_raw", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",           limit: 255
    t.string  "region",              limit: 255
    t.string  "country",             limit: 255
    t.string  "reason_change",       limit: 255
    t.decimal "estimate"
    t.float   "population_variance"
    t.decimal "guess_min"
    t.decimal "guess_max"
  end

  create_table "add_sums_region_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",                limit: 255
    t.string  "region",                   limit: 255
    t.string  "reason_change"
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
    t.float   "meta_population_variance"
  end

  create_table "add_totals_continent_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
  end

  create_table "add_totals_country_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.string  "country",       limit: 255
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
  end

  create_table "add_totals_region_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.string  "region",        limit: 255
    t.decimal "estimate"
    t.float   "confidence"
    t.float   "guess_min"
    t.float   "guess_max"
  end

  create_table "analyses", force: :cascade do |t|
    t.string   "analysis_name"
    t.integer  "comparison_year"
    t.integer  "analysis_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backup_analyses", id: false, force: :cascade do |t|
    t.string   "analysis_name"
    t.integer  "comparison_year"
    t.integer  "analysis_year"
    t.integer  "id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backup_changes", id: false, force: :cascade do |t|
    t.integer  "id"
    t.string   "analysis_name",    limit: 255
    t.integer  "analysis_year"
    t.string   "replacement_name", limit: 255
    t.string   "replaced_strata",  limit: 255
    t.string   "new_strata",       limit: 255
    t.string   "reason_change",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country",          limit: 255
    t.integer  "analysis_id"
    t.string   "status"
    t.text     "comments"
  end

  create_table "cause_of_changes", id: false, force: :cascade do |t|
    t.string  "code",          limit: 4
    t.string  "name",          limit: 100
    t.integer "display_order"
  end

  create_table "changes", force: :cascade do |t|
    t.string   "analysis_name",    limit: 255
    t.integer  "analysis_year"
    t.string   "replacement_name", limit: 255
    t.string   "replaced_strata",  limit: 512
    t.string   "new_strata",       limit: 512
    t.string   "reason_change",    limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "country",          limit: 255
    t.integer  "analysis_id"
    t.string   "status"
    t.text     "comments"
    t.string   "population"
    t.string   "sort_key"
  end

  create_table "continent", primary_key: "gid", force: :cascade do |t|
    t.string   "continent",  limit: 10
    t.integer  "definite"
    t.integer  "probable"
    t.integer  "possible"
    t.integer  "specul"
    t.integer  "cntryarea"
    t.integer  "rangearea"
    t.integer  "knownrange"
    t.integer  "possrange"
    t.integer  "doubtrange"
    t.integer  "pa_area"
    t.integer  "surveyarea"
    t.integer  "protrang"
    t.integer  "survrang"
    t.float    "rangeknown"
    t.float    "rangeperc"
    t.float    "paperc"
    t.float    "surveyperc"
    t.float    "protrangpe"
    t.float    "survrangpe"
    t.float    "probfracti"
    t.float    "infqltyidx"
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.geometry "geom",       limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "continents", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso_code",    limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.boolean  "is_surveyed"
  end

  create_table "country", primary_key: "gid", force: :cascade do |t|
    t.string   "ccode",      limit: 2
    t.string   "cntryname",  limit: 50
    t.string   "fr_cntryna", limit: 35
    t.integer  "rangestate", limit: 2
    t.string   "regionid",   limit: 2
    t.integer  "faocode",    limit: 2
    t.string   "region",     limit: 20
    t.integer  "definite"
    t.integer  "probable"
    t.integer  "possible"
    t.integer  "specul"
    t.integer  "cntryarea"
    t.integer  "rangearea"
    t.integer  "knownrange"
    t.integer  "possrange"
    t.integer  "doubtrange"
    t.integer  "pa_area"
    t.integer  "surveyarea"
    t.integer  "protrang"
    t.integer  "survrang"
    t.float    "rangeknown"
    t.float    "rangeperc"
    t.float    "paperc"
    t.float    "surveyperc"
    t.float    "protrangpe"
    t.float    "survrangpe"
    t.float    "probfracti"
    t.float    "infqltyidx"
    t.integer  "citeshunti", limit: 2
    t.string   "citesappen", limit: 2
    t.integer  "listingyr",  limit: 2
    t.string   "rainyseaso", limit: 12
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.geometry "geom",       limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  add_index "country", ["geom"], name: "si_country_geom", using: :gist

  create_table "country_pa", id: false, force: :cascade do |t|
    t.string   "country",        limit: 50
    t.integer  "stated"
    t.geometry "protected_area", limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "country_pa_metrics", id: false, force: :cascade do |t|
    t.string  "country",             limit: 50
    t.integer "stated"
    t.float   "protected_area_sqkm"
    t.float   "percent_protected"
  end

  create_table "country_pa_range", id: false, force: :cascade do |t|
    t.string   "country",              limit: 50
    t.integer  "stated"
    t.geometry "protected_area_range", limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "country_pa_range_metrics", id: false, force: :cascade do |t|
    t.string  "country",                   limit: 50
    t.integer "stated"
    t.float   "range_sqkm"
    t.float   "protected_area_range_sqkm"
    t.float   "percent_protected_range"
  end

  create_table "country_range", id: false, force: :cascade do |t|
    t.string   "country",        limit: 50
    t.decimal  "range",                                                precision: 10
    t.string   "range_quality",  limit: 10
    t.geometry "range_geometry", limit: {:srid=>0, :type=>"geometry"}
  end

  add_index "country_range", ["range_geometry"], name: "si_country_range", using: :gist

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
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "continent",     limit: 255
    t.text    "category"
    t.float   "definite"
    t.float   "probable"
    t.float   "possible"
    t.float   "speculative"
  end

  create_table "dpps_sums_continent_category_reason", id: false, force: :cascade do |t|
    t.string  "analysis_name"
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
    t.string  "analysis_name"
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
    t.string  "analysis_name"
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
    t.string  "analysis_name"
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
    t.string  "analysis_name"
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

  create_table "julian_2007", primary_key: "gid", force: :cascade do |t|
    t.string   "inpcode",    limit: 6
    t.string   "ccode",      limit: 2
    t.string   "cntryname",  limit: 30
    t.string   "surveyzone", limit: 80
    t.integer  "cyear",      limit: 2
    t.string   "cseason",    limit: 10
    t.string   "method",     limit: 2
    t.integer  "tcrate",     limit: 2
    t.float    "effsampint"
    t.float    "sampint"
    t.integer  "pilenum",    limit: 2
    t.integer  "drmsite",    limit: 2
    t.float    "ddcl95p"
    t.integer  "estimate"
    t.integer  "actualseen"
    t.integer  "uprange",    limit: 2
    t.float    "stderror"
    t.float    "variance"
    t.float    "cl95"
    t.float    "cl95p"
    t.float    "ucl95asym"
    t.float    "lcl95asym"
    t.integer  "carcass12"
    t.integer  "carcass3"
    t.integer  "carcasst"
    t.string   "reference",  limit: 100
    t.integer  "refid"
    t.string   "call_numbe", limit: 30
    t.integer  "quality",    limit: 2
    t.string   "category",   limit: 1
    t.string   "surveytype", limit: 80
    t.integer  "pfs"
    t.integer  "definite"
    t.integer  "probable"
    t.integer  "possible"
    t.integer  "specul"
    t.float    "density"
    t.float    "cratio12"
    t.float    "cratiot"
    t.integer  "selection",  limit: 2
    t.date     "datein"
    t.date     "dateout"
    t.string   "comments",   limit: 254
    t.string   "designate",  limit: 50
    t.string   "abvdesigna", limit: 10
    t.integer  "area_sqkm"
    t.integer  "reported"
    t.integer  "derived"
    t.integer  "calculated"
    t.integer  "scaledenom"
    t.integer  "report",     limit: 2
    t.integer  "df",         limit: 2
    t.integer  "nsample",    limit: 2
    t.decimal  "t025"
    t.decimal  "lon"
    t.decimal  "lat"
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.geometry "geom",       limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  create_table "linked_citations", force: :cascade do |t|
    t.string   "long_citation"
    t.string   "short_citation"
    t.string   "url"
    t.text     "description"
    t.integer  "population_submission_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "mike_sites", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "subregion",  limit: 255
    t.string   "site_code",  limit: 255
    t.text     "site_name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.boolean  "in2015list"
  end

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

  create_table "population_submission_geometries", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.geometry "geom",                                limit: {:srid=>0, :type=>"geometry"}
    t.text     "geom_attributes"
    t.integer  "population_submission_attachment_id"
    t.integer  "stratum"
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
    t.text     "comments"
    t.string   "internal_name"
  end

  create_table "production_versions", id: false, force: :cascade do |t|
    t.integer  "id",                         default: "nextval('production_versions_id_seq'::regclass)", null: false
    t.string   "item_type",      limit: 255,                                                             null: false
    t.integer  "item_id",                                                                                null: false
    t.string   "event",          limit: 255,                                                             null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  create_table "protected_area_geometries", id: false, force: :cascade do |t|
    t.integer  "gid"
    t.decimal  "ptacode",                                               precision: 10
    t.string   "ptaname",    limit: 254
    t.string   "ccode",      limit: 254
    t.decimal  "year_est",                                              precision: 10
    t.string   "iucncat",    limit: 254
    t.decimal  "iucncatara",                                            precision: 10
    t.string   "designate",  limit: 254
    t.string   "abvdesig",   limit: 254
    t.decimal  "area_sqkm",                                             precision: 10
    t.decimal  "reported",                                              precision: 10
    t.decimal  "calculated",                                            precision: 10
    t.string   "source",     limit: 254
    t.decimal  "refid",                                                 precision: 10
    t.decimal  "inrange",                                               precision: 10
    t.decimal  "samesurvey",                                            precision: 10
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.decimal  "selection",                                             precision: 10
    t.geometry "geometry",   limit: {:srid=>0, :type=>"multi_polygon"}
  end

  create_table "range_discrepancies", id: false, force: :cascade do |t|
    t.integer "gid"
    t.integer "actual"
    t.float   "calculated"
    t.integer "range",      limit: 2
    t.string  "rangequali", limit: 10
    t.text    "centroid"
  end

  create_table "range_geometries", id: false, force: :cascade do |t|
    t.integer  "gid"
    t.decimal  "range",                                                    precision: 10
    t.string   "rangequali", limit: 10
    t.geometry "geometry",   limit: {:srid=>4326, :type=>"multi_polygon"}
  end

  add_index "range_geometries", ["geometry"], name: "si_range_geometry", using: :gist

  create_table "range_previews", force: :cascade do |t|
    t.string   "range_type"
    t.string   "original_comments"
    t.string   "source_year"
    t.string   "published_year"
    t.string   "comments"
    t.string   "status"
    t.geometry "geom",              limit: {:srid=>0, :type=>"geometry"}
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  create_table "region", primary_key: "gid", force: :cascade do |t|
    t.string   "regionid",   limit: 254
    t.string   "region",     limit: 20
    t.string   "continent",  limit: 10
    t.string   "fr_region",  limit: 20
    t.integer  "definite"
    t.integer  "probable"
    t.integer  "possible"
    t.integer  "specul"
    t.integer  "cntryarea"
    t.integer  "rangearea"
    t.integer  "knownrange"
    t.integer  "possrange"
    t.integer  "doubtrange"
    t.integer  "pa_area"
    t.integer  "surveyarea"
    t.integer  "protrang"
    t.float    "rangeknown"
    t.integer  "survrang"
    t.float    "rangeperc"
    t.float    "paperc"
    t.float    "surveyperc"
    t.float    "protrangpe"
    t.float    "survrangpe"
    t.float    "probfracti"
    t.float    "infqltyidx"
    t.decimal  "shape_leng"
    t.decimal  "shape_area"
    t.geometry "geom",       limit: {:srid=>4326, :type=>"multi_polygon"}
  end

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

  create_table "review_range", id: false, force: :cascade do |t|
    t.string   "site_name",           limit: 255
    t.string   "analysis_name"
    t.integer  "analysis_year"
    t.string   "region",              limit: 255
    t.text     "category"
    t.string   "reason_change",       limit: 255
    t.integer  "population_estimate"
    t.string   "country",             limit: 255
    t.text     "input_zone_id"
    t.geometry "survey_geometry",     limit: {:srid=>4326, :type=>"multi_polygon", :has_z=>true, :has_m=>true}
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

  create_table "st_est_loc_geo_tb", primary_key: "sid", force: :cascade do |t|
    t.integer  "id"
    t.text     "estimate_type"
    t.text     "input_zone_id"
    t.integer  "population_submission_id"
    t.string   "site_name",                         limit: 255
    t.string   "stratum_name",                      limit: 255
    t.integer  "stratum_area"
    t.integer  "completion_year"
    t.string   "short_citation",                    limit: 255
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_confidence_interval"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "quality_level"
    t.integer  "actually_seen"
    t.float    "lcl95"
    t.text     "category"
    t.string   "country",                           limit: 255
    t.string   "region",                            limit: 255
    t.string   "continent",                         limit: 255
    t.geometry "geometry",                          limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "staging_users", id: false, force: :cascade do |t|
    t.integer  "id",                                 default: "nextval('staging_users_id_seq'::regclass)", null: false
    t.string   "email",                  limit: 255, default: "",                                          null: false
    t.string   "encrypted_password",     limit: 128, default: "",                                          null: false
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
  end

  create_table "static_estimate_factors_with_geometry", primary_key: "gid", force: :cascade do |t|
    t.integer  "id"
    t.text     "estimate_type"
    t.text     "input_zone_id"
    t.integer  "population_submission_id"
    t.string   "site_name",                         limit: 255
    t.string   "stratum_name",                      limit: 255
    t.integer  "stratum_area"
    t.integer  "completion_year"
    t.text     "citation"
    t.string   "short_citation",                    limit: 255
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_confidence_interval"
    t.float    "population_t"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "quality_level"
    t.integer  "actually_seen"
    t.integer  "survey_geometry_id"
    t.geometry "geometry",                          limit: {:srid=>0, :type=>"geometry"}
  end

  create_table "static_estimate_locator_with_geometry", primary_key: "gid", force: :cascade do |t|
    t.integer  "id"
    t.geometry "geometry",                          limit: {:srid=>0, :type=>"geometry"}
    t.text     "estimate_type"
    t.text     "input_zone_id"
    t.integer  "population_submission_id"
    t.string   "site_name",                         limit: 255
    t.string   "stratum_name",                      limit: 255
    t.integer  "stratum_area"
    t.integer  "completion_year"
    t.text     "analysis_name"
    t.integer  "analysis_year"
    t.integer  "age"
    t.string   "replacement_name",                  limit: 255
    t.string   "reason_change"
    t.text     "citation"
    t.string   "short_citation",                    limit: 255
    t.integer  "population_estimate"
    t.float    "population_variance"
    t.float    "population_standard_error"
    t.float    "population_confidence_interval"
    t.integer  "population_lower_confidence_limit"
    t.integer  "population_upper_confidence_limit"
    t.integer  "quality_level"
    t.integer  "actually_seen"
    t.float    "lcl95"
    t.text     "category"
    t.string   "country",                           limit: 255
    t.string   "region",                            limit: 255
    t.string   "continent",                         limit: 255
  end

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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
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
    t.float    "transects_covered_total_length"
    t.float    "strip_width"
    t.integer  "observations"
    t.string   "observations_distance_method",                      limit: 255
    t.integer  "actually_seen"
    t.integer  "dung_piles"
    t.string   "dung_decay_rate_measurement_method",                limit: 255
    t.float    "dung_decay_rate_estimate_used"
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
    t.float    "defecation_rate_estimate_used"
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
    t.float    "dung_encounter_rate"
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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
  end

  create_table "survey_faecal_dnas", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.boolean  "surveyed_at_stratum_level"
    t.boolean  "stratum_level_data_submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_geometries", force: :cascade do |t|
    t.geometry "geom",        limit: {:srid=>0, :type=>"geometry"}
    t.string   "attribution"
  end

  add_index "survey_geometries", ["geom"], name: "si_survey_geom", using: :gist

  create_table "survey_geometry_locator_buffered", id: false, force: :cascade do |t|
    t.string   "site_name",           limit: 255
    t.text     "analysis_name"
    t.integer  "analysis_year"
    t.string   "region",              limit: 255
    t.text     "category"
    t.string   "reason_change",       limit: 255
    t.integer  "population_estimate"
    t.string   "country",             limit: 255
    t.text     "input_zone_id"
    t.geometry "survey_geometry",     limit: {:srid=>0, :type=>"geometry"}
  end

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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
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
    t.string   "web_id"
    t.text     "comments"
    t.string   "internal_name"
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
    t.string   "web_id"
    t.integer  "stratum_area"
  end

  create_table "survey_modeled_extrapolations", force: :cascade do |t|
    t.integer  "population_submission_id"
    t.string   "other_method_description"
    t.integer  "population_estimate_min"
    t.integer  "population_estimate_max"
    t.integer  "mike_site_id"
    t.boolean  "is_mike_site"
    t.integer  "actually_seen"
    t.boolean  "informed"
    t.integer  "survey_geometry_id"
    t.integer  "stratum_area"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "web_id"
    t.integer  "stratum_area"
  end

  create_table "survey_range_equator_countries", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "region",        limit: 255
    t.string  "range_quality", limit: 10
    t.text    "category"
    t.string  "country",       limit: 255
    t.float   "area_sqkm"
  end

  create_table "survey_range_intersection_metrics", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "region",        limit: 255
    t.string  "range_quality", limit: 10
    t.text    "category"
    t.string  "reason_change", limit: 255
    t.string  "country",       limit: 255
    t.float   "area_sqkm"
  end

  create_table "survey_range_intersection_metrics_add", id: false, force: :cascade do |t|
    t.string  "analysis_name"
    t.integer "analysis_year"
    t.string  "region",        limit: 255
    t.string  "range_quality", limit: 10
    t.text    "category"
    t.string  "reason_change", limit: 255
    t.string  "country",       limit: 255
    t.float   "area_sqkm"
  end

  create_table "survey_range_intersections", id: false, force: :cascade do |t|
    t.string   "analysis_name"
    t.integer  "analysis_year"
    t.string   "region",          limit: 255
    t.text     "category"
    t.string   "reason_change",   limit: 255
    t.string   "country",         limit: 255
    t.string   "range_quality",   limit: 10
    t.geometry "st_intersection", limit: {:srid=>0, :type=>"geometry"}
  end

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

  add_foreign_key "changes", "analyses", name: "fk_analysis"
  add_foreign_key "population_submission_attachments", "population_submissions", name: "fk1_pop_submission"
  add_foreign_key "population_submissions", "submissions", name: "submission_fk"
  add_foreign_key "species_range_state_countries", "species", name: "fk_species"
  add_foreign_key "submissions", "mike_sites", name: "fk1_mike_site"
  add_foreign_key "submissions", "species", name: "fk1_species"
  add_foreign_key "submissions", "users", name: "fk1_user"
  add_foreign_key "survey_aerial_sample_count_strata", "mike_sites", name: "fk_mike1"
  add_foreign_key "survey_aerial_sample_count_strata", "survey_aerial_sample_counts", name: "fk_as"
  add_foreign_key "survey_aerial_sample_count_strata", "survey_geometries", name: "fk6_geom"
  add_foreign_key "survey_aerial_sample_counts", "population_submissions", name: "fk2_pop_submission"
  add_foreign_key "survey_aerial_total_count_strata", "mike_sites", name: "fk_mike2"
  add_foreign_key "survey_aerial_total_count_strata", "survey_aerial_total_counts", name: "fk_at"
  add_foreign_key "survey_aerial_total_count_strata", "survey_geometries", name: "fk5_geom"
  add_foreign_key "survey_aerial_total_counts", "population_submissions", name: "fk3_pop_submission"
  add_foreign_key "survey_dung_count_line_transect_strata", "mike_sites", name: "fk_mike3"
  add_foreign_key "survey_dung_count_line_transect_strata", "survey_dung_count_line_transects", name: "fk_dc"
  add_foreign_key "survey_dung_count_line_transect_strata", "survey_geometries", name: "fk4_geom"
  add_foreign_key "survey_dung_count_line_transects", "population_submissions", name: "fk4_pop_submission"
  add_foreign_key "survey_faecal_dna_strata", "mike_sites", name: "fk_mike4"
  add_foreign_key "survey_faecal_dna_strata", "survey_faecal_dnas", name: "fk_dna"
  add_foreign_key "survey_faecal_dna_strata", "survey_geometries", name: "fk3_geom"
  add_foreign_key "survey_faecal_dnas", "population_submissions", name: "fk5_pop_submission"
  add_foreign_key "survey_ground_sample_count_strata", "mike_sites", name: "fk_mike6"
  add_foreign_key "survey_ground_sample_count_strata", "survey_geometries", name: "fk2_geom"
  add_foreign_key "survey_ground_sample_count_strata", "survey_ground_sample_counts", name: "fk_gs"
  add_foreign_key "survey_ground_sample_counts", "population_submissions", name: "fk6_pop_submission"
  add_foreign_key "survey_ground_sample_counts", "population_submissions", name: "fk7_pop_submission"
  add_foreign_key "survey_ground_total_count_strata", "mike_sites", name: "fk_mike5"
  add_foreign_key "survey_ground_total_count_strata", "survey_geometries", name: "fk1_geom"
  add_foreign_key "survey_ground_total_count_strata", "survey_ground_total_counts", name: "fk_gt"
  add_foreign_key "survey_individual_registrations", "mike_sites", name: "fk_mike8"
  add_foreign_key "survey_individual_registrations", "population_submissions", name: "fk8_pop_submission"
  add_foreign_key "survey_individual_registrations", "survey_geometries", name: "fk8_geom"
  add_foreign_key "survey_others", "mike_sites", name: "fk_mike5"
  add_foreign_key "survey_others", "population_submissions", name: "fk9_pop_submission"
  add_foreign_key "survey_others", "survey_geometries", name: "fk9_geom"
end
