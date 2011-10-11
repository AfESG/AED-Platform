class SurveyDungCountLineTransectsController < ApplicationController
  # GET /survey_dung_count_line_transects
  # GET /survey_dung_count_line_transects.xml
  def index
    @survey_dung_count_line_transects = SurveyDungCountLineTransect.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transects }
    end
  end

  # GET /survey_dung_count_line_transects/1
  # GET /survey_dung_count_line_transects/1.xml
  def show
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transect }
    end
  end

  # GET /survey_dung_count_line_transects/new
  # GET /survey_dung_count_line_transects/new.xml
  def new
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_dung_count_line_transect }
    end
  end

  # GET /survey_dung_count_line_transects/1/edit
  def edit
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.find(params[:id])
  end

  # POST /survey_dung_count_line_transects
  # POST /survey_dung_count_line_transects.xml
  def create
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.new(params[:survey_dung_count_line_transect])

    respond_to do |format|
      if @survey_dung_count_line_transect.save
        format.html { redirect_to(@survey_dung_count_line_transect, :notice => 'Survey dung count line transect was successfully created.') }
        format.xml  { render :xml => @survey_dung_count_line_transect, :status => :created, :location => @survey_dung_count_line_transect }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_dung_count_line_transect.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_dung_count_line_transects/1
  # PUT /survey_dung_count_line_transects/1.xml
  def update
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.find(params[:id])

    respond_to do |format|
      if @survey_dung_count_line_transect.update_attributes(params[:survey_dung_count_line_transect])
        format.html { redirect_to(@survey_dung_count_line_transect, :notice => 'Survey dung count line transect was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_dung_count_line_transect.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_dung_count_line_transects/1
  # DELETE /survey_dung_count_line_transects/1.xml
  def destroy
    @survey_dung_count_line_transect = SurveyDungCountLineTransect.find(params[:id])
    @survey_dung_count_line_transect.destroy

    respond_to do |format|
      format.html { redirect_to(survey_dung_count_line_transects_url) }
      format.xml  { head :ok }
    end
  end
end
