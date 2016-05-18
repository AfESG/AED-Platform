class AnalysesController < ApplicationController

  include GeoRuby::SimpleFeatures
  require 'geo_ruby/shp'
  require 'geo_ruby/ewk'

  before_filter :authenticate_superuser!

  # GET /analyses
  # GET /analyses.json
  def index
    @analyses = Analysis.order(:analysis_name,:analysis_year)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @analyses }
    end
  end

  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  # GET /analyses/1
  # GET /analyses/1.json
  def show
    @analysis = Analysis.find(params[:id])

    # Get all the relevant rows from the view stack
    estimates = execute <<-SQL
      select * from estimate_factors_analyses_categorized
        where analysis_name='#{@analysis.analysis_name}';
    SQL

    # Turn them into a map for handy fetching
    @estimates = {}
    @used_estimates = {}
    estimates.each do |estimate|
      @estimates[estimate['input_zone_id']+'@'+estimate['analysis_year']] = estimate
      @used_estimates[estimate['input_zone_id']] = true
    end

    respond_to do |format|
      format.html {
        render layout: 'fullscreen'
      }
      format.json { render json: @analysis }
    end
  end

  # GET /analyses/new
  # GET /analyses/new.json
  def new
    @analysis = Analysis.new

    respond_to do |format|
      format.html
      format.json { render json: @analysis }
    end
  end

  # GET /analyses/1/edit
  def edit
    @analysis = Analysis.find(params[:id])
  end

  # POST /analyses
  # POST /analyses.json
  def create
    @analysis = Analysis.new(params[:analysis])

    respond_to do |format|
      if @analysis.save
        source = params[:copy_from]
        p params
        if source != ''
          copied_changes = []
          Change.where(analysis_name: source).each do |source_change|
            copied_changes << {
              analysis_name: @analysis.analysis_name,
              analysis_year: source_change.analysis_year,
              replacement_name: source_change.replacement_name,
              replaced_strata: source_change.replaced_strata,
              new_strata: source_change.new_strata,
              country: source_change.country,
              reason_change: source_change.reason_change,
              analysis: @analysis,
              status: 'Needs review'
            }
          end
          Change.create copied_changes
        end
        format.html { redirect_to @analysis, notice: 'Analysis was successfully created.' }
        format.json { render json: @analysis, status: :created, location: @analysis }
      else
        format.html { render action: "new" }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analyses/1
  # PUT /analyses/1.json
  def update
    @analysis = Analysis.find(params[:id])

    respond_to do |format|
      if @analysis.update_attributes(params[:analysis])
        format.html { redirect_to @analysis, notice: 'Analysis was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analyses/1
  # DELETE /analyses/1.json
  def destroy
    @analysis = Analysis.find(params[:id])
    @analysis.destroy

    respond_to do |format|
      format.html { redirect_to analyses_url }
      format.json { head :no_content }
    end
  end

  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def export
    @export = execute <<-SQL, params[:analysis], params[:year]
      SELECT
        row_number() over () as id,
        *
      FROM input_zone_export
      WHERE
      analysis=? and ayear=?
    SQL

    input_filenames = ["export.shp", "export.dbf", "export.shx"]
    input_filenames.each do |filename|
      File.delete(filename) rescue nil
    end

    puts "Adding features to shapefile"
    fn = "export.shp"
    shpfile = GeoRuby::Shp4r::ShpFile.create(fn, GeoRuby::Shp4r::ShpType::POLYGON, [
        GeoRuby::Shp4r::Dbf::Field.new('id', 'N', 10),
        GeoRuby::Shp4r::Dbf::Field.new('analysis', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('ayear', 'N', 10),
        GeoRuby::Shp4r::Dbf::Field.new('region', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('country', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('inpzone', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('site', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('stratum', 'C', 30),
        GeoRuby::Shp4r::Dbf::Field.new('strcode', 'C', 10),
        GeoRuby::Shp4r::Dbf::Field.new('est_type', 'C', 15),
        GeoRuby::Shp4r::Dbf::Field.new('category', 'C', 4),
        GeoRuby::Shp4r::Dbf::Field.new('year', 'C', 6),
        GeoRuby::Shp4r::Dbf::Field.new('rc', 'C', 4),
        GeoRuby::Shp4r::Dbf::Field.new('full_cit', 'C', 254),
        GeoRuby::Shp4r::Dbf::Field.new('short_cit', 'C', 254),
        GeoRuby::Shp4r::Dbf::Field.new('estimate', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('variance', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('std_err', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('ci', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('lcl', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('ucl', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('lcl95', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('quality', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('seen', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('area_rep', 'N', 10, 3),
        GeoRuby::Shp4r::Dbf::Field.new('area_calc', 'N', 10, 3)
      ])
    shpfile.transaction do |tr|
      @export.each do |row|
        puts "Adding feature #{row['sgid']} to shapefile"
        mp = MultiPolygon.from_ewkb(SurveyGeometry.find(row['sgid']).geom.as_binary)
        properties = row.select { |key, value| !key.match(/sgid.*/) }
        p properties
        record = GeoRuby::Shp4r::ShpRecord.new(mp, properties)
        tr.add(record)
      end
    end

    zipfile_name = 'export-analysis-' + params[:analysis] + '-' + params[:year] + '.zip'

    File.delete(zipfile_name) rescue nil

    puts "Creating Zip"
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
