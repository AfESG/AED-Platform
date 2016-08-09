class RegionsController < ApplicationController
  include CheckYearHelper
  include NarrativeHelper
  before_action :check_year!
  include CachesMap

  def index
    render json: { regions: Region.all }
  end

  def geojson_strata
    render json: {
        type: 'FeatureCollection',
        features: region.countries.map(&:features).flatten
    }
  end

  def geojson_map
    geojson = simplify > 0 ? region.geojson_map_simple(simplify) : region.geojson_map
    render json: geojson
  end

  def dpps
    render json: region.dpps(year)
  end

  def add
    render json: region.add(year)
  end

  def countries
    render json: { countries: region.countries }
  end

  def narrative
    boilerplate = region.narrative_boilerplate(2015)
    render json: { narrative: "<p>#{boilerplate}</p>" + fake_narrative_content }
  end

  def boilerplate_data
    render json: region.narrative_boilerplate_data(2015)
  end

  private
  def region
    Region.find_by_id(params[:id])
  end

  def year
    params[:year] || 2013
  end

  def simplify
    params[:simplify].to_f * 0.1
  end
end
