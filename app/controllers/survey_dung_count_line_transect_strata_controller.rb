class SurveyDungCountLineTransectStrataController < ApplicationController
  # GET /survey_dung_count_line_transect_strata
  # GET /survey_dung_count_line_transect_strata.xml
  def index
    @survey_dung_count_line_transect_strata = SurveyDungCountLineTransectStratum.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transect_strata }
    end
  end

  # GET /survey_dung_count_line_transect_strata/1
  # GET /survey_dung_count_line_transect_strata/1.xml
  def show
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transect_stratum }
    end
  end

  # GET /survey_dung_count_line_transect_strata/new
  # GET /survey_dung_count_line_transect_strata/new.xml
  def new
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transect_stratum }
    end
  end

  # GET /survey_dung_count_line_transect_strata/1/edit
  def edit
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.find(params[:id])
  end

  # POST /survey_dung_count_line_transect_strata
  # POST /survey_dung_count_line_transect_strata.xml
  def create
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.new(params[:survey_dung_count_line_transect_stratum])

    respond_to do |format|
      if @survey_dung_count_line_transect_stratum.save
        format.html { redirect_to(@survey_dung_count_line_transect_stratum, :notice => 'Survey dung count line transect stratum was successfully created.') }
        format.xml  { render :xml => @survey_dung_count_line_transect_stratum, :status => :created, :location => @survey_dung_count_line_transect_stratum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_dung_count_line_transect_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_dung_count_line_transect_strata/1
  # PUT /survey_dung_count_line_transect_strata/1.xml
  def update
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.find(params[:id])

    respond_to do |format|
      if @survey_dung_count_line_transect_stratum.update_attributes(params[:survey_dung_count_line_transect_stratum])
        format.html { redirect_to(@survey_dung_count_line_transect_stratum, :notice => 'Survey dung count line transect stratum was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_dung_count_line_transect_stratum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_dung_count_line_transect_strata/1
  # DELETE /survey_dung_count_line_transect_strata/1.xml
  def destroy
    @survey_dung_count_line_transect_stratum = SurveyDungCountLineTransectStratum.find(params[:id])
    @survey_dung_count_line_transect_stratum.destroy

    respond_to do |format|
      format.html { redirect_to(survey_dung_count_line_transect_strata_url) }
      format.xml  { head :ok }
    end
  end
end
