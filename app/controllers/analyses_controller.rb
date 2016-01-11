class AnalysesController < ApplicationController

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
      format.html # show.html.erb
      format.json { render json: @analysis }
    end
  end

  # GET /analyses/new
  # GET /analyses/new.json
  def new
    @analysis = Analysis.new

    respond_to do |format|
      format.html # new.html.erb
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

end
