class PopulationsController < ApplicationController
  include CheckYearHelper
  before_action :check_year!
  include CachesMap

  def index
    render json: { populations: Population.all }
  end

  def geojson_map
    render json: population.geojson
  end

  def input_zones
    render json: { input_zones: population.input_zones }
  end

  private
  def population
    Population.find_by_id(params[:id])
  end

  def year
    params[:year] || 2013
  end

  def simplify
    params[:simplify].to_f * 0.1
  end
end
