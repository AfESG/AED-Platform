class ContinentsController < ApplicationController
  def index
    render json: { regions: Continent.all }
  end

  def geojson_map
    @continent = Continent.find_by_id(params[:id])
    render json: {
        type: 'FeatureCollection',
        features: @continent.countries.map(&:features).flatten
    }
  end
end
