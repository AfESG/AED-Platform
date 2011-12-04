class PopulationSubmissionsController < ApplicationController
  # GET /population_submissions
  # GET /population_submissions.xml
  def index
    @population_submissions = PopulationSubmission.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @population_submissions }
    end
  end

  # GET /population_submissions/1
  # GET /population_submissions/1.xml
  def show
    @population_submission = PopulationSubmission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @population_submission }
    end
  end

  # GET /population_submissions/new
  # GET /population_submissions/new.xml
  def new
    @population_submission = PopulationSubmission.new
    @submission = Submission.find params[:submission_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @population_submission }
    end
  end

  # GET /population_submissions/1/edit
  def edit
    @population_submission = PopulationSubmission.find(params[:id])
  end

  # POST /population_submissions
  # POST /population_submissions.xml
  def create
    @population_submission = PopulationSubmission.new(params[:population_submission])

    respond_to do |format|
      if @population_submission.save
        format.html { redirect_to(@population_submission, :notice => 'Population submission was successfully created.') }
        format.xml  { render :xml => @population_submission, :status => :created, :location => @population_submission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @population_submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /population_submissions/1
  # PUT /population_submissions/1.xml
  def update
    @population_submission = PopulationSubmission.find(params[:id])

    respond_to do |format|
      if @population_submission.update_attributes(params[:population_submission])
        format.html { redirect_to(@population_submission, :notice => 'Population submission was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @population_submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /population_submissions/1
  # DELETE /population_submissions/1.xml
  def destroy
    @population_submission = PopulationSubmission.find(params[:id])
    @population_submission.destroy

    respond_to do |format|
      format.html { redirect_to(population_submissions_url) }
      format.xml  { head :ok }
    end
  end
end
