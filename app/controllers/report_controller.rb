class ReportController < ApplicationController

  def country
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')
  end

end
