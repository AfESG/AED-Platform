class SurveyGeometriesController < ApplicationController

  def geojson_map
    @survey_geometry = SurveyGeometry.find(params[:id])
    feature = RGeo::GeoJSON.encode(@survey_geometry.geom)
    render :json => feature
  end

end
