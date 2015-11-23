require 'zip'
require 'rgeo/shapefile'

class PopulationSubmissionAttachmentsController < ApplicationController
  include SurveyCrud

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.population_submission = PopulationSubmission.find(params[:population_submission_id])
  end

  def download
    head(:not_found) and return if (attachment = PopulationSubmissionAttachment.find_by_id(params[:id])).nil?
    path = attachment.file.path
    # uri = attachment.file.s3_object.url_for(:read, :secure => false, :expires_in => 10.seconds, :response_content_disposition => 'attachment' )
    redirect_to path.to_s
  end

  def unzip_file (file, destination)
    shapefile = nil
    Zip::File.open(file) { |zip_file|
     zip_file.each { |f|
       f_path=File.join(destination, f.name)
       if f_path.downcase.end_with?('.shp')
         shapefile = f_path
       end
       FileUtils.mkdir_p(File.dirname(f_path))
       zip_file.extract(f, f_path) unless File.exist?(f_path)
     }
    }
    return shapefile
  end

  def import_geometries_from_shapefile(shapefile)
    population_submission = @attachment.population_submission
    RGeo::Shapefile::Reader.open(shapefile) do |file|
      puts "File contains #{file.num_records} records."
      file.each do |record|
        puts "Record number #{record.index}:"
        puts "  Geometry: #{record.geometry.as_text}"
        puts "  Attributes: #{record.attributes.inspect}"
        population_submission_geometry = population_submission.population_submission_geometries.create
        population_submission_geometry.geom = record.geometry
        population_submission_geometry.geom_attributes = record.attributes.to_json
        population_submission_geometry.save!
      end
    end
  end

  def create
    @attachment = level_class.new(params[level_base_name])
    if @attachment.save
      puts @attachment.file.inspect
      if @attachment.file.path.downcase.end_with?('.zip')
        shapefile = unzip_file(@attachment.file.path, File.dirname(@attachment.file.path));
        import_geometries_from_shapefile shapefile if shapefile
      end
      redirect_to @attachment
    else
      render :action => "new"
    end
  end

end
