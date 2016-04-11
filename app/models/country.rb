class Country < ActiveRecord::Base
  has_paper_trail

  # this model is not web-serviceable
  # attr_accessible

  has_many :species_range_state_countries
  has_many :species, :through => :species_range_state_countries # , :source => :species_range_state_country
  has_many :mike_sites
  has_many :submissions

  belongs_to :region

  def to_s
    name
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
end
