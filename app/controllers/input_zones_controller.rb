class InputZonesController < ApplicationController
  include CheckYearHelper
  before_action :check_year!
  include CachesMap

  def index
    render json: { input_zones: InputZone.select(:id, :name, :analysis_year, :analysis_name, :population_id) }
  end

  def data
    render json: input_zone
  end

  def geojson_map
    render json: input_zone.geojson
  end

  def strata
    render json: { strata: input_zone.strata(year) }
  end

  private
  def input_zone
    InputZone.find_by_id(params[:id])
  end

  def year
    params[:year] || AedUtils.analysis_years.max
  end

  def simplify
    params[:simplify].to_f * 0.1
  end
end
