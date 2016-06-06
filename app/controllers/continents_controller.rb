class ContinentsController < ApplicationController
  def index
    render json: { continents: Continent.all }
  end

  def map
    render json: {
        type: 'FeatureCollection',
        features: continent.countries.map(&:features).flatten
    }
  end

  def dpps
    render json: continent.dpps(year)
  end

  def add
    render json: continent.add(year)
  end

  private
  def continent
    Continent.find_by_id(params[:id])
  end

  def year
    params[:year] || 2013
  end
end
