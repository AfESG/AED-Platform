class ReportNarrativesController < ApplicationController
  # GET /report_narratives
  # GET /report_narratives.json
  def index
    @report_narratives = ReportNarrative.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @report_narratives }
    end
  end

  # GET /report_narratives/1
  # GET /report_narratives/1.json
  def show
    @report_narrative = ReportNarrative.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report_narrative }
    end
  end

  # GET /report_narratives/new
  # GET /report_narratives/new.json
  def new
    @report_narrative = ReportNarrative.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report_narrative }
    end
  end

  # GET /report_narratives/1/edit
  def edit
    @report_narrative = ReportNarrative.find(params[:id])
  end

  # POST /report_narratives
  # POST /report_narratives.json
  def create
    @report_narrative = ReportNarrative.new(params[:report_narrative])

    respond_to do |format|
      if @report_narrative.save
        format.html { redirect_to @report_narrative, notice: 'Report narrative was successfully created.' }
        format.json { render json: @report_narrative, status: :created, location: @report_narrative }
      else
        format.html { render action: "new" }
        format.json { render json: @report_narrative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /report_narratives/1
  # PUT /report_narratives/1.json
  def update
    @report_narrative = ReportNarrative.find(params[:id])

    respond_to do |format|
      if @report_narrative.update_attributes(params[:report_narrative])
        format.html { redirect_to @report_narrative, notice: 'Report narrative was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @report_narrative.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_narratives/1
  # DELETE /report_narratives/1.json
  def destroy
    @report_narrative = ReportNarrative.find(params[:id])
    @report_narrative.destroy

    respond_to do |format|
      format.html { redirect_to report_narratives_url }
      format.json { head :ok }
    end
  end
end
