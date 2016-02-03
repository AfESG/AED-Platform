class CountriesController < ApplicationController
  def geojson_map
    @country = Country.where(iso_code: params[:iso_code]).first
    features = []
    @country.submissions.includes(:population_submissions).each do |submission|
      submission.population_submissions.each do |population_submission|
        count = population_submission.counts[0]
        next unless count
        if count.has_strata?
          count.strata.includes(:survey_geometry).each do |stratum|
            if stratum.survey_geometry
              feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
              if feature
                feature['properties'] = {
                  'aed_stratum' => "#{population_submission.survey_type}#{stratum.id}",
                  'uri' => "/#{stratum.class.name.pluralize.underscore}/#{stratum.id}",
                  'aed_name' => stratum.stratum_name,
                  'aed_year' => population_submission.completion_year,
                  'aed_citation' => population_submission.short_citation,
                  'aed_area' => stratum.stratum_area,
                  'aed_estimate' => stratum.population_estimate
                }
                features << feature
              end
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
    features.sort_by! { |h| h['properties']['aed_year'] }
    feature_collection = {
      'type' => 'FeatureCollection',
      'features' => features
    }
    render :json => feature_collection
  end

  def geojson_map_public
    analysis = Analysis.where(analysis_name: params[:analysis]).first
    year = params[:year].to_i
    features = []
    analysis.input_zones.where(country: params[:iso_code]).each do |input_zone|
      strata = []
      if analysis.comparison_year == year
        strata = input_zone.fetch_replaced_strata
      elsif analysis.analysis_year == year
        strata = input_zone.fetch_new_strata
      end
      strata.each do |stratum|
        if stratum.survey_geometry
          population_submission = stratum.parent_count.population_submission
          feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
          feature['properties'] = {
            'aed_stratum' => "#{population_submission.survey_type}#{stratum.id}",
            'uri' => "/#{stratum.class.name.pluralize.underscore}/#{stratum.id}",
            'aed_name' => stratum.stratum_name,
            'aed_year' => population_submission.completion_year,
            'aed_citation' => population_submission.short_citation,
            'aed_area' => stratum.stratum_area,
            'aed_estimate' => stratum.population_estimate
          }
          features << feature
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
