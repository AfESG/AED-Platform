class SurveyGeometriesController < ApplicationController

  include GeoRuby::SimpleFeatures
  require 'geo_ruby/shp'
  require 'geo_ruby/ewk'

  def geojson_map
    @survey_geometry = SurveyGeometry.find(params[:id])
    feature = RGeo::GeoJSON.encode(@survey_geometry.geom)
    render :json => feature
  end

  def download
    i = params[:id]
    @survey_geometry = SurveyGeometry.find(i)
    fn = "#{i}.shp"
    shpfile = GeoRuby::Shp4r::ShpFile.create(fn, GeoRuby::Shp4r::ShpType::POLYGON, [])
    shpfile.transaction do |tr|
      mp = MultiPolygon.from_ewkb(@survey_geometry.geom.as_binary)
      record = GeoRuby::Shp4r::ShpRecord.new(mp,{})
      tr.add(record)
    end

    input_filenames = ["#{i}.shp", "#{i}.dbf", "#{i}.shx"]
    zipfile_name = "#{i}.zip"
    File.delete(zipfile_name) rescue nil

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, filename)
      end
    end
    input_filenames.each do |filename|
      File.delete(filename)
    end

    send_file zipfile_name, :type => "application/octet-stream", :x_sendfile => true
  end

end
