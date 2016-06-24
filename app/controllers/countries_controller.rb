class CountriesController < ApplicationController
  include CheckYearHelper
  before_action :check_year!

  def index
    render json: { countries: Country.all }
  end

  def geojson_strata
    render json: {
      type: 'FeatureCollection',
      features: country.features
    }
  end

  def geojson_map
    render json: country.geojson_map
  end

  def dpps
    render json: { data: country.dpps(year), strata: country.strata(year) }
  end

  def add
    render json: { data: country.add(year), strata: country.strata(year) }
  end

  def geojson_map_public
    analysis = Analysis.where(analysis_name: params[:analysis]).first
    year = params[:year].to_i
    features = []
    analysis.input_zones.where(country: params[:iso_code].upcase).each do |input_zone|
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

  private
  def country
    Country.find_by_iso_code(params[:iso_code].upcase)
  end

  def year
    params[:year] || 2013
  end
end
