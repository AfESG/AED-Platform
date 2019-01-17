class ContinentsController < ApplicationController
  include CheckYearHelper
  include NarrativeHelper
  before_action :check_year!
  include CachesMap

  def index
    render json: { continents: Continent.all }
  end

  def geojson_strata
    render json: {
        type: 'FeatureCollection',
        features: continent.countries.map(&:features).flatten
    }
  end

  def geojson_map
    geojson = simplify > 0 ? continent.geojson_map_simple(simplify) : continent.geojson_map
    render json: geojson
  end

  def dpps
    render json: continent.dpps(year)
  end

  def add
    render json: continent.add(year)
  end

  def regions
    render json: continent.regions.all
  end

  def narrative
    boilerplate = continent.narrative_boilerplate(2015)
    render json: { narrative: "<p>#{boilerplate}</p>" + fake_narrative_content }
  end

  def boilerplate_data
    render json: continent.narrative_boilerplate_data(2015)
  end

  private
  def continent
    Continent.find_by_id(params[:id])
  end

  def year
    params[:year] || Analysis.published.maximum(:analysis_year)
  end

  def simplify
    params[:simplify].to_f * 0.1
  end
end
