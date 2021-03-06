class Country < ActiveRecord::Base
  include AltDppsHelper
  include DppsCountryHelper
  include TotalizerHelper
  include DppsCountryPreviousHelper
  include NarrativeBoilerplates

  has_paper_trail

  # this model is not web-serviceable
  # attr_accessible

  has_many :species_range_state_countries
  has_many :species, :through => :species_range_state_countries # , :source => :species_range_state_country
  has_many :mike_sites
  has_many :submissions
  has_many :populations

  belongs_to :region

  def to_s
    name
  end

  def escaped_name
    ActiveRecord::Base.connection.instance_variable_get(:@connection).escape(name)
  end

  def features
    features = []

    submissions.includes(:population_submissions).each do |submission|
      submission.population_submissions.each do |population_submission|
        count = population_submission.counts.first
        next unless count

        if count.has_strata?
          count.strata.includes(:survey_geometry).each do |stratum|
            next unless stratum.survey_geometry
            feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
            if feature
              feature['properties'] = {
                  aed_stratum: "#{population_submission.survey_type}#{stratum.id}",
                  uri: "/#{stratum.class.name.pluralize.underscore}/#{stratum.id}",
                  aed_name: stratum.stratum_name,
                  aed_internal_name: stratum.internal_name || '',
                  aed_year: population_submission.completion_year,
                  aed_citation: population_submission.short_citation,
                  aed_area: stratum.stratum_area,
                  aed_estimate: stratum.population_estimate
              }
              features << feature
            end
          end

        else
          next unless count.survey_geometry
          feature = RGeo::GeoJSON.encode(count.survey_geometry.geom)
          if feature
            feature['properties'] = {
                aed_stratum: "#{population_submission.survey_type}#{count.id}",
                uri: "/#{count.class.name.pluralize.underscore}/#{count.id}",
                aed_name: population_submission.site_name,
                aed_area: population_submission.area,
                aed_year: population_submission.completion_year,
                aed_citation: population_submission.short_citation,
                aed_estimate: (count.population_estimate rescue count.population_estimate_min)
            }
            features << feature
          end
        end

      end
    end

    features.sort_by { |h| h['properties'][:aed_year] }
  end

  def geojson_map_simple(simplify = 0.0)
    country_name = (name == 'Sudan' ? 'South Sudan' : name) # fix for Sudan vs. South Sudan
    sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geom, ?), 10) as "geo" FROM country WHERE cntryname = ?'
    execute(sql, simplify, country_name).first['geo']
  end

  def geojson_map
    country_name = (name == 'Sudan' ? 'South Sudan' : name) # fix for Sudan vs. South Sudan
    sql = 'SELECT ST_AsGeoJSON(geom, 10) as "geo" FROM country WHERE cntryname = ?'
    execute(sql, country_name).first['geo']
  end

  def dpps(year)
    begin
      if AedLegacy.legacy_year?(year)
        {
            country: name,
            year: year
        }.merge(get_country_previous_values(name, year))
      else
        filter = Analysis.find_by_analysis_year(year).analysis_name
        {
            country: name,
            year: year,
            analysis_name: filter,
            country_totals: execute(totalizer("country='#{escaped_name}'", filter, year))
        }.merge(get_country_values(name, filter, year))
      end
    rescue
      { data: nil }
    end
  end

  def add(year)
    analysis = Analysis.find_by_analysis_year(year)
    filter = analysis.try(:analysis_name)
    args = ["country='#{escaped_name}'", year, filter]
    {
        country: name,
        year: year,
        assessed_range: assessed_range(year),
        analysis_name: filter,
        summary_totals: execute(alt_dpps(*args)),
        summary_sums: execute(alt_dpps_totals(*args)),
        baseline_year: analysis.try(:comparison_year),
        summary_baseline: analysis.try(:comparison_year) ?
            execute(alt_dpps_totals("country='#{escaped_name}'", analysis.comparison_year, filter)) :
            nil,
        areas: execute(alt_dpps_country_area(*args)),
        causes_of_change: execute(alt_dpps_causes_of_change(*args)),
        causes_of_change_sums: execute(alt_dpps_causes_of_change_sums(*args)),
        areas_by_reason: execute(alt_dpps_country_area_by_reason(*args))
    }
  end

  def strata(year)
    sql = 'SELECT * FROM input_zone_export WHERE country = ? AND ayear = ?'
    execute(sql, name, year)
  end

  def self.add_dump
    where.not(region_id: nil).order(:name).map do |c|
      year = AedUtils.analysis_years.max
      analysis = Analysis.find_by(analysis_year: year)

      filter = analysis.analysis_name
      args = ["country='#{c.escaped_name}'", year, filter]
      {
          country: c.name,
          year: year,
          analysis_name: filter,
          summary_sums: execute(c.alt_dpps_totals(*args)),
          causes_of_change_sums: execute(c.alt_dpps_causes_of_change_sums(*args)),
      }
    end
  end

  def self.add_csv_dump
    dump = add_dump
    headers = dump.first.map do |key, val|
      val.is_a?(PG::Result) ? val.fields.map { |k| "#{key}__#{k}" } : key
    end.flatten.map(&:downcase)
    rows = dump.map do |row|
      row.values.map { |v| v.is_a?(PG::Result) ? v.values : v }.flatten.map(&:to_s)
    end
    CSV.generate(headers: true) { |csv| ([headers] + rows).each { |row| csv << row }}
  end

  def assessed_range(year)
    sql = 'SELECT "ASSESSED_RANGE" as range FROM country_range_totals WHERE country = ? AND analysis_year = ? LIMIT 1'
    execute(sql, name, year).first['range'] rescue nil
  end

  def estimates
    sql = <<-SQL
SELECT
  analysis_year,
  "ESTIMATE" AS estimate
FROM estimate_factors_analyses_categorized_totals_country_for_add
WHERE country = ?
ORDER BY analysis_year;
    SQL
    execute(sql, name).to_a
  end

  def dpps_summary(year)
    sql = <<-sql
SELECT
  sc.definite                      AS "DEFINITE",
  sc.possible                      AS "POSSIBLE",
  sc.probable                      AS "PROBABLE",
  speculative                      AS "SPECUL",
  ROUND(rm.range_area)             AS "RANGEAREA",
  ROUND(rm.percent_regional_range) AS "RANGEPERC",
  ROUND(rm.percent_range_assessed) AS "SURVRANGPERC"
FROM
  dpps_sums_country sc
  JOIN regional_range_table rm USING (country, analysis_year)
WHERE sc.country = ? AND analysis_year = ?
    sql
    execute(sql, name, year).first
  end

  def input_zones
    populations.includes(:input_zones).reduce([]) do |list, p|
      list += p.input_zones.select(:id, :name, :analysis_year, :population_id)
    end
  end

  private
  def self.execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end

  def execute(*array)
    self.class.execute(*array)
  end
end
