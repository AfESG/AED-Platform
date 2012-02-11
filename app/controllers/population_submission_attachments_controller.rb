class PopulationSubmissionAttachmentsController < ApplicationController
  # GET /population_submission_attachments
  # GET /population_submission_attachments.json
  def index
    @population_submission_attachments = PopulationSubmissionAttachment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @population_submission_attachments }
    end
  end

  # GET /population_submission_attachments/1
  # GET /population_submission_attachments/1.json
  def show
    @population_submission_attachment = PopulationSubmissionAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @population_submission_attachment }
    end
  end

  # GET /population_submission_attachments/new
  # GET /population_submission_attachments/new.json
  def new
    @population_submission_attachment = PopulationSubmissionAttachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @population_submission_attachment }
    end
  end

  # GET /population_submission_attachments/1/edit
  def edit
    @population_submission_attachment = PopulationSubmissionAttachment.find(params[:id])
  end

  # POST /population_submission_attachments
  # POST /population_submission_attachments.json
  def create
    @population_submission_attachment = PopulationSubmissionAttachment.new(params[:population_submission_attachment])

    respond_to do |format|
      if @population_submission_attachment.save
        format.html { redirect_to @population_submission_attachment, notice: 'Population submission attachment was successfully created.' }
        format.json { render json: @population_submission_attachment, status: :created, location: @population_submission_attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @population_submission_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /population_submission_attachments/1
  # PUT /population_submission_attachments/1.json
  def update
    @population_submission_attachment = PopulationSubmissionAttachment.find(params[:id])

    respond_to do |format|
      if @population_submission_attachment.update_attributes(params[:population_submission_attachment])
        format.html { redirect_to @population_submission_attachment, notice: 'Population submission attachment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @population_submission_attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /population_submission_attachments/1
  # DELETE /population_submission_attachments/1.json
  def destroy
    @population_submission_attachment = PopulationSubmissionAttachment.find(params[:id])
    @population_submission_attachment.destroy

    respond_to do |format|
      format.html { redirect_to population_submission_attachments_url }
      format.json { head :ok }
    end
  end
end
