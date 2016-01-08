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

  # GET /analyses/1
  # GET /analyses/1.json
  def show
    @Analysis = Analysis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @Analysis }
    end
  end

  # GET /analyses/new
  # GET /analyses/new.json
  def new
    @Analysis = Analysis.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @Analysis }
    end
  end

  # GET /analyses/1/edit
  def edit
    @Analysis = Analysis.find(params[:id])
  end

  # POST /analyses
  # POST /analyses.json
  def create
    @Analysis = Analysis.new(params[:Analysis])

    respond_to do |format|
      if @Analysis.save
        format.html { redirect_to @Analysis, notice: 'Analysis was successfully created.' }
        format.json { render json: @Analysis, status: :created, location: @Analysis }
      else
        format.html { render action: "new" }
        format.json { render json: @Analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /analyses/1
  # PUT /analyses/1.json
  def update
    @Analysis = Analysis.find(params[:id])

    respond_to do |format|
      if @Analysis.update_attributes(params[:Analysis])
        format.html { redirect_to @Analysis, notice: 'Analysis was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @Analysis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /analyses/1
  # DELETE /analyses/1.json
  def destroy
    @Analysis = Analysis.find(params[:id])
    @Analysis.destroy

    respond_to do |format|
      format.html { redirect_to analyses_url }
      format.json { head :no_content }
    end
  end

end
