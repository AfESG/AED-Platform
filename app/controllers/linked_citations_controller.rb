class LinkedCitationsController < ApplicationController

  before_filter :authenticate_superuser!

  # GET /linked_citations
  # GET /linked_citations.json
  def index
    @linked_citations = LinkedCitation.order(:short_citation,:long_citation)
    @population_submission = PopulationSubmission.find(params[:population_submission_id])
    @submission = @population_submission.submission
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @linked_citations }
    end
  end

  # GET /linked_citations/1
  # GET /linked_citations/1.json
  def show
    @linked_citation = LinkedCitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @linked_citation }
    end
  end

  # GET /linked_citations/new
  # GET /linked_citations/new.json
  def new
    @linked_citation = LinkedCitation.new
    @population_submission = PopulationSubmission.find(params[:population_submission_id])
    @submission = @population_submission.submission

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @linked_citation }
    end
  end

  # GET /linked_citations/1/edit
  def edit
    @linked_citation = LinkedCitation.find(params[:id])
    @population_submission = PopulationSubmission.find(params[:population_submission_id])
    @submission = @population_submission.submission
  end

  # POST /linked_citations
  # POST /linked_citations.json
  def create
    @linked_citation = LinkedCitation.new(params[:linked_citation])

    respond_to do |format|
      if @linked_citation.save
        format.html { redirect_to population_submission_linked_citations_path(@linked_citation.population_submission_id) }
        format.json { render json: @linked_citation, status: :created, location: @linked_citation }
      else
        format.html { render action: "new" }
        format.json { render json: @linked_citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /linked_citations/1
  # PUT /linked_citations/1.json
  def update
    @linked_citation = LinkedCitation.find(params[:id])

    respond_to do |format|
      if @linked_citation.update_attributes(params[:linked_citation])
        format.html { redirect_to population_submission_linked_citations_path(@linked_citation.population_submission_id) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @linked_citation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /linked_citations/1
  # DELETE /linked_citations/1.json
  def destroy
    @linked_citation = LinkedCitation.find(params[:id])
    @population_submission_id = @linked_citation.population_submission_id
    @linked_citation.destroy

    respond_to do |format|
      format.html { redirect_to population_submission_linked_citations_path(@population_submission_id) }
      format.json { head :no_content }
    end
  end

end
