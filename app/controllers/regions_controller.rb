class RegionsController < ApplicationController
  def index
    render json: { regions: Region.all }
  end

  def geojson_map
    @region = Region.find_by_id(params[:id])
    render json: {
        type: 'FeatureCollection',
        features: @region.countries.map(&:features).flatten
    }
  end
end
