class SurveyAerialSampleCountStrataController < ApplicationController
  # GET /survey_aerial_sample_count_strata
  # GET /survey_aerial_sample_count_strata.xml
  def index
    @survey_aerial_sample_count_strata = SurveyAerialSampleCountStratum.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_aerial_sample_count_strata }
    end
  end

  # GET /survey_aerial_sample_count_strata/1
  # GET /survey_aerial_sample_count_strata/1.xml
  def show
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_aerial_sample_count_stratum }
    end
  end

  # GET /survey_aerial_sample_count_strata/new
  # GET /survey_aerial_sample_count_strata/new.xml
  def new
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_aerial_sample_count_stratum }
    end
  end

  # GET /survey_aerial_sample_count_strata/1/edit
  def edit
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.find(params[:id])
  end

  # POST /survey_aerial_sample_count_strata
  # POST /survey_aerial_sample_count_strata.xml
  def create
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.new(params[:survey_aerial_sample_count_stratum])

    respond_to do |format|
      if @survey_aerial_sample_count_stratum.save
        format.html { redirect_to(@survey_aerial_sample_count_stratum, :notice => 'Survey aerial sample count stratum was successfully created.') }
        format.xml  { render :xml => @survey_aerial_sample_count_stratum, :status => :created, :location => @survey_aerial_sample_count_stratum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_aerial_sample_count_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_aerial_sample_count_strata/1
  # PUT /survey_aerial_sample_count_strata/1.xml
  def update
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.find(params[:id])

    respond_to do |format|
      if @survey_aerial_sample_count_stratum.update_attributes(params[:survey_aerial_sample_count_stratum])
        format.html { redirect_to(@survey_aerial_sample_count_stratum, :notice => 'Survey aerial sample count stratum was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_aerial_sample_count_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_aerial_sample_count_strata/1
  # DELETE /survey_aerial_sample_count_strata/1.xml
  def destroy
    @survey_aerial_sample_count_stratum = SurveyAerialSampleCountStratum.find(params[:id])
    @survey_aerial_sample_count_stratum.destroy

    respond_to do |format|
      format.html { redirect_to(survey_aerial_sample_count_strata_url) }
      format.xml  { head :ok }
    end
  end
end
