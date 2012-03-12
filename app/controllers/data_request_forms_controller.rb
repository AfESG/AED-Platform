class DataRequestFormsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter :authenticate_superuser!, :only => [:index]

  def index
    @data_request_forms = DataRequestForm.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_request_forms }
    end
  end

  def show
    @data_request_form = DataRequestForm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @data_request_form }
    end
  end

  def new
    @data_request_form = DataRequestForm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_request_form }
    end
  end

  def edit
    @data_request_form = DataRequestForm.find(params[:id])
  end

  def create
    @data_request_form = DataRequestForm.new(params[:data_request_form])

    respond_to do |format|
      if @data_request_form.save
        AdminNotifier.data_request_form_submitted(@data_request_form, current_user).deliver
        AdminNotifier.data_request_form_thanks(@data_request_form, current_user).deliver
        format.html { redirect_to :action =>'thanks' }
        format.xml  { render :xml => @data_request_form, :status => :created, :location => @data_request_form }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @data_request_form.errors, :status => :unprocessable_entity }
      end
    end
  end

  def thanks
  end

  def update
    @data_request_form = DataRequestForm.find(params[:id])

    if @data_request_form.update_attributes(params[:data_request_form])
      redirect_to @data_request_form, :notice => 'Data request form was successfully updated.', :only_path => true
    else
      render :action => "edit"
    end
  end

  def destroy
    @data_request_form = DataRequestForm.find(params[:id])
    @data_request_form.destroy

    respond_to do |format|
      format.html { redirect_to(data_request_forms_url) }
      format.xml  { head :ok }
    end
  end
end
