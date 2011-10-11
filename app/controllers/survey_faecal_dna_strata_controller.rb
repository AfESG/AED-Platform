class SurveyFaecalDnaStrataController < ApplicationController
  # GET /survey_faecal_dna_strata
  # GET /survey_faecal_dna_strata.xml
  def index
    @survey_faecal_dna_strata = SurveyFaecalDnaStratum.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_faecal_dna_strata }
    end
  end

  # GET /survey_faecal_dna_strata/1
  # GET /survey_faecal_dna_strata/1.xml
  def show
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_faecal_dna_stratum }
    end
  end

  # GET /survey_faecal_dna_strata/new
  # GET /survey_faecal_dna_strata/new.xml
  def new
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_faecal_dna_stratum }
    end
  end

  # GET /survey_faecal_dna_strata/1/edit
  def edit
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.find(params[:id])
  end

  # POST /survey_faecal_dna_strata
  # POST /survey_faecal_dna_strata.xml
  def create
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.new(params[:survey_faecal_dna_stratum])

    respond_to do |format|
      if @survey_faecal_dna_stratum.save
        format.html { redirect_to(@survey_faecal_dna_stratum, :notice => 'Survey faecal dna stratum was successfully created.') }
        format.xml  { render :xml => @survey_faecal_dna_stratum, :status => :created, :location => @survey_faecal_dna_stratum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_faecal_dna_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_faecal_dna_strata/1
  # PUT /survey_faecal_dna_strata/1.xml
  def update
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.find(params[:id])

    respond_to do |format|
      if @survey_faecal_dna_stratum.update_attributes(params[:survey_faecal_dna_stratum])
        format.html { redirect_to(@survey_faecal_dna_stratum, :notice => 'Survey faecal dna stratum was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_faecal_dna_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_faecal_dna_strata/1
  # DELETE /survey_faecal_dna_strata/1.xml
  def destroy
    @survey_faecal_dna_stratum = SurveyFaecalDnaStratum.find(params[:id])
    @survey_faecal_dna_stratum.destroy

    respond_to do |format|
      format.html { redirect_to(survey_faecal_dna_strata_url) }
      format.xml  { head :ok }
    end
  end
end
