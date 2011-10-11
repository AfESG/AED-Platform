class SurveyOthersController < ApplicationController
  # GET /survey_others
  # GET /survey_others.xml
  def index
    @survey_others = SurveyOther.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_others }
    end
  end

  # GET /survey_others/1
  # GET /survey_others/1.xml
  def show
    @survey_other = SurveyOther.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_other }
    end
  end

  # GET /survey_others/new
  # GET /survey_others/new.xml
  def new
    @survey_other = SurveyOther.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_other }
    end
  end

  # GET /survey_others/1/edit
  def edit
    @survey_other = SurveyOther.find(params[:id])
  end

  # POST /survey_others
  # POST /survey_others.xml
  def create
    @survey_other = SurveyOther.new(params[:survey_other])

    respond_to do |format|
      if @survey_other.save
        format.html { redirect_to(@survey_other, :notice => 'Survey other was successfully created.') }
        format.xml  { render :xml => @survey_other, :status => :created, :location => @survey_other }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_other.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_others/1
  # PUT /survey_others/1.xml
  def update
    @survey_other = SurveyOther.find(params[:id])

    respond_to do |format|
      if @survey_other.update_attributes(params[:survey_other])
        format.html { redirect_to(@survey_other, :notice => 'Survey other was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_other.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_others/1
  # DELETE /survey_others/1.xml
  def destroy
    @survey_other = SurveyOther.find(params[:id])
    @survey_other.destroy

    respond_to do |format|
      format.html { redirect_to(survey_others_url) }
      format.xml  { head :ok }
    end
  end
end
