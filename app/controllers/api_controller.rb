class ApiController < ApplicationController
  def autocomplete
  end

  def dump
    respond_to do |format|
      format.json { render json: Country.add_dump }
      format.csv { send_data(Country.add_csv_dump, filename: 'dump.csv') }
    end
  end

  def help
  end
end
