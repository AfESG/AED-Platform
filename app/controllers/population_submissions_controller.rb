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
    @submission = @population_submission.submission

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
    @submission = @population_submission.submission
  end

  # POST /population_submissions
  # POST /population_submissions.xml
  def create
    @population_submission = PopulationSubmission.new(params[:population_submission])

    respond_to do |format|
      if @population_submission.save
        if @population_submission.survey_type == 'AS'
          format.html { redirect_to new_population_submission_survey_aerial_sample_count_path(@population_submission) }
        elsif @population_submission.survey_type == 'AT'
          format.html { redirect_to new_population_submission_survey_aerial_total_count_path(@population_submission) }
        elsif @population_submission.survey_type == 'GS'
          format.html { redirect_to new_population_submission_survey_ground_sample_count_path(@population_submission) }
        elsif @population_submission.survey_type == 'GT'
          format.html { redirect_to new_population_submission_survey_ground_total_count_path(@population_submission) }
        elsif @population_submission.survey_type == 'DC'
          format.html { redirect_to new_population_submission_survey_dung_count_line_transect_path(@population_submission) }
        elsif @population_submission.survey_type == 'GD'
          format.html { redirect_to new_population_submission_survey_faecal_dna_path(@population_submission) }
        elsif @population_submission.survey_type == 'IR'
          format.html { redirect_to new_population_submission_survey_individual_registration_path(@population_submission) }
        else
          format.html { render "Unsupported survey type. This is almost certainly a bug." }
        end
      else
        @submission = @population_submission.submission
        format.html { render :action => "new" }
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
