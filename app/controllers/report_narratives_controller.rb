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

  def redirect_for(uri)
    if uri =~ /_report/
      return "/preview"+uri
    else
      return "/report/"+uri
    end
  end

  # GET /report_narratives/1
  # GET /report_narratives/1.json
  def show
    @report_narrative = ReportNarrative.find(params[:id])
    redirect_to redirect_for(@report_narrative.uri), :only_path => true
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
    @report_narrative.uri = @report_narrative.uri.gsub(' ','_').gsub('%20','_')
    if @report_narrative.save
      redirect_to redirect_for(@report_narrative.uri), :only_path => true
    else
      render action: "new"
    end
  end

  # PUT /report_narratives/1
  # PUT /report_narratives/1.json
  def update
    @report_narrative = ReportNarrative.find(params[:id])

    if @report_narrative.update_attributes(params[:report_narrative])
      @report_narrative.uri = @report_narrative.uri.gsub(' ','_').gsub('%20','_')
      @report_narrative.save
      redirect_to redirect_for(@report_narrative.uri), :only_path => true
    else
      render action: "edit"
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
