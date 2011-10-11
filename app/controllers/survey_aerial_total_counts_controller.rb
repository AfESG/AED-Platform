class SurveyAerialTotalCountsController < ApplicationController
  # GET /survey_aerial_total_counts
  # GET /survey_aerial_total_counts.xml
  def index
    @survey_aerial_total_counts = SurveyAerialTotalCount.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @survey_aerial_total_counts }
    end
  end

  # GET /survey_aerial_total_counts/1
  # GET /survey_aerial_total_counts/1.xml
  def show
    @survey_aerial_total_count = SurveyAerialTotalCount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey_aerial_total_count }
    end
  end

  # GET /survey_aerial_total_counts/new
  # GET /survey_aerial_total_counts/new.xml
  def new
    @survey_aerial_total_count = SurveyAerialTotalCount.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey_aerial_total_count }
    end
  end

  # GET /survey_aerial_total_counts/1/edit
  def edit
    @survey_aerial_total_count = SurveyAerialTotalCount.find(params[:id])
  end

  # POST /survey_aerial_total_counts
  # POST /survey_aerial_total_counts.xml
  def create
    @survey_aerial_total_count = SurveyAerialTotalCount.new(params[:survey_aerial_total_count])

    respond_to do |format|
      if @survey_aerial_total_count.save
        format.html { redirect_to(@survey_aerial_total_count, :notice => 'Survey aerial total count was successfully created.') }
        format.xml  { render :xml => @survey_aerial_total_count, :status => :created, :location => @survey_aerial_total_count }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey_aerial_total_count.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /survey_aerial_total_counts/1
  # PUT /survey_aerial_total_counts/1.xml
  def update
    @survey_aerial_total_count = SurveyAerialTotalCount.find(params[:id])

    respond_to do |format|
      if @survey_aerial_total_count.update_attributes(params[:survey_aerial_total_count])
        format.html { redirect_to(@survey_aerial_total_count, :notice => 'Survey aerial total count was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey_aerial_total_count.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_aerial_total_counts/1
  # DELETE /survey_aerial_total_counts/1.xml
  def destroy
    @survey_aerial_total_count = SurveyAerialTotalCount.find(params[:id])
    @survey_aerial_total_count.destroy

    respond_to do |format|
      format.html { redirect_to(survey_aerial_total_counts_url) }
      format.xml  { head :ok }
    end
  end
end
