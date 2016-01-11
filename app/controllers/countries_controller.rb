class CountriesController < ApplicationController
  def geojson_map
    @country = Country.where(iso_code: params[:iso_code]).first
    features = []
    @country.submissions.each do |submission|
      submission.population_submissions.order(:completion_year).each do |population_submission|
        count = population_submission.counts[0]
        next unless count
        if count.has_strata?
          count.strata.each do |stratum|
            if stratum.survey_geometry
              feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
              feature['properties'] = {
                'aed_stratum' => "#{population_submission.survey_type}#{stratum.id}",
                'uri' => "/#{stratum.class.name.pluralize.underscore}/#{stratum.id}",
                'aed_name' => stratum.stratum_name,
                'aed_area' => stratum.stratum_area,
                'aed_estimate' => stratum.population_estimate,
                'aed_year' => population_submission.completion_year
              }
              features << feature
            end
          end
        else
          if count.survey_geometry
            feature = RGeo::GeoJSON.encode(count.survey_geometry.geom)
            feature['properties'] = {
              'aed_stratum' => "#{population_submission.survey_type}#{count.id}",
              'uri' => "/#{count.class.name.pluralize.underscore}/#{count.id}",
              'aed_name' => population_submission.site_name,
              'aed_area' => population_submission.area,
              'aed_year' => population_submission.completion_year,
              'aed_estimate' => (count.population_estimate rescue count.population_estimate_min)
            }
            features << feature
          end
        end
      end
    end
    feature_collection = {
      'type' => 'FeatureCollection',
      'features' => features
    }
    render :json => feature_collection
  end
end
