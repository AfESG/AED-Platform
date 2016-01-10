class CountriesController < ApplicationController
  def geojson_map
    @country = Country.where(iso_code: params[:iso_code]).first
    features = []
    @country.submissions.each do |submission|
      submission.population_submissions.each do |population_submission|
        next unless population_submission.counts[0]
        population_submission.counts[0].strata.each do |stratum|
          if stratum.survey_geometry
            feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
            feature['properties'] = {
              'aed_stratum' => stratum.id,
              'aed_name' => stratum.stratum_name,
              'aed_area' => stratum.stratum_area,
              'aed_estimate' => stratum.population_estimate
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
