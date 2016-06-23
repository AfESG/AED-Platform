class ContinentsController < ApplicationController
  include CheckYearHelper
  before_action :check_year!

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
    render json: continent.geojson_map
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

  private
  def continent
    Continent.find_by_id(params[:id])
  end

  def year
    params[:year] || 2013
  end
end
