class SurveyIndividualRegistrationsController < ApplicationController
  # GET /survey_individual_registrations
  # GET /survey_individual_registrations.xml
  def index
    @survey_individual_registrations = SurveyIndividualRegistration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_individual_registrations }
    end
  end

  # GET /survey_individual_registrations/1
  # GET /survey_individual_registrations/1.xml
  def show
    @survey_individual_registration = SurveyIndividualRegistration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_individual_registration }
    end
  end

  # GET /survey_individual_registrations/new
  # GET /survey_individual_registrations/new.xml
  def new
    @survey_individual_registration = SurveyIndividualRegistration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_individual_registration }
    end
  end

  # GET /survey_individual_registrations/1/edit
  def edit
    @survey_individual_registration = SurveyIndividualRegistration.find(params[:id])
  end

  # POST /survey_individual_registrations
  # POST /survey_individual_registrations.xml
  def create
    @survey_individual_registration = SurveyIndividualRegistration.new(params[:survey_individual_registration])

    respond_to do |format|
      if @survey_individual_registration.save
        format.html { redirect_to(@survey_individual_registration, :notice => 'Survey individual registration was successfully created.') }
        format.xml  { render :xml => @survey_individual_registration, :status => :created, :location => @survey_individual_registration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_individual_registration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_individual_registrations/1
  # PUT /survey_individual_registrations/1.xml
  def update
    @survey_individual_registration = SurveyIndividualRegistration.find(params[:id])

    respond_to do |format|
      if @survey_individual_registration.update_attributes(params[:survey_individual_registration])
        format.html { redirect_to(@survey_individual_registration, :notice => 'Survey individual registration was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_individual_registration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_individual_registrations/1
  # DELETE /survey_individual_registrations/1.xml
  def destroy
    @survey_individual_registration = SurveyIndividualRegistration.find(params[:id])
    @survey_individual_registration.destroy

    respond_to do |format|
      format.html { redirect_to(survey_individual_registrations_url) }
      format.xml  { head :ok }
    end
  end
end
