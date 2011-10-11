class SurveyFaecalDnasController < ApplicationController
  # GET /survey_faecal_dnas
  # GET /survey_faecal_dnas.xml
  def index
    @survey_faecal_dnas = SurveyFaecalDna.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_faecal_dnas }
    end
  end

  # GET /survey_faecal_dnas/1
  # GET /survey_faecal_dnas/1.xml
  def show
    @survey_faecal_dna = SurveyFaecalDna.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_faecal_dna }
    end
  end

  # GET /survey_faecal_dnas/new
  # GET /survey_faecal_dnas/new.xml
  def new
    @survey_faecal_dna = SurveyFaecalDna.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_faecal_dna }
    end
  end

  # GET /survey_faecal_dnas/1/edit
  def edit
    @survey_faecal_dna = SurveyFaecalDna.find(params[:id])
  end

  # POST /survey_faecal_dnas
  # POST /survey_faecal_dnas.xml
  def create
    @survey_faecal_dna = SurveyFaecalDna.new(params[:survey_faecal_dna])

    respond_to do |format|
      if @survey_faecal_dna.save
        format.html { redirect_to(@survey_faecal_dna, :notice => 'Survey faecal dna was successfully created.') }
        format.xml  { render :xml => @survey_faecal_dna, :status => :created, :location => @survey_faecal_dna }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_faecal_dna.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_faecal_dnas/1
  # PUT /survey_faecal_dnas/1.xml
  def update
    @survey_faecal_dna = SurveyFaecalDna.find(params[:id])

    respond_to do |format|
      if @survey_faecal_dna.update_attributes(params[:survey_faecal_dna])
        format.html { redirect_to(@survey_faecal_dna, :notice => 'Survey faecal dna was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_faecal_dna.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_faecal_dnas/1
  # DELETE /survey_faecal_dnas/1.xml
  def destroy
    @survey_faecal_dna = SurveyFaecalDna.find(params[:id])
    @survey_faecal_dna.destroy

    respond_to do |format|
      format.html { redirect_to(survey_faecal_dnas_url) }
      format.xml  { head :ok }
    end
  end
end
