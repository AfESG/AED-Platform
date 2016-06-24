class ApiController < ApplicationController
  def autocomplete
  end

  def dump
    respond_to do |format|
      format.json { render json: Country.add_dump }
      format.csv { send_data(Country.add_csv_dump, filename: 'dump.csv') }
    end
  end

  def help
  end

  def strata_geojson
    sql = 'SELECT ST_AsGeoJSON(sg.geom) as "geo" FROM estimate_factors ef
           LEFT JOIN survey_geometries sg ON (ef.survey_geometry_id = sg.id)
           WHERE ef.input_zone_id = ?'
    render json: execute(sql, params[:strcode].upcase).first['geo']
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end
end
