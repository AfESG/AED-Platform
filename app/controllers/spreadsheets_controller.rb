require 'roo'

class SpreadsheetsController < ApplicationController
  include AltDppsHelper
  include SpreadsheetsHelper

  before_filter :authenticate_user!
  before_filter :ensure_admin!

  def index
    @files = Dir.glob("#{directory}/*")
    @sheets = []

    @files.each do |file|
      @sheets << { name: File.basename(file), created_at: File.mtime(file) }
    end
  end

  def destroy
    path = File.join directory, filename
    if File.exists? path
      File.delete path

      redirect_to spreadsheets_path, notice: 'Spreadsheet successfully deleted.'
    else
      redirect_to spreadsheets_path, alert: 'Spreadsheet not found, perhaps it has been deleted.'
    end
  end

  def create
    file      = params[:file]
    name      = file.original_filename

    if valid_filename? name
      FileUtils.mkdir_p(directory) unless File.exists?(directory)
      path = File.join(directory, name)

      File.open(path, 'wb') do |f|
        f.write file.read
      end

      redirect_to spreadsheet_path(name)
    else
      redirect_to spreadsheets_path, alert: 'Invalid filename, could not save spreadsheet. Please use only letters, numbers, dashes, and underscores.'
    end
  end

  def show
    path  = File.join directory, filename
    if File.exists?(path)
      @xlsx = Roo::Spreadsheet.open(path)

      data_point_cols = { 'CATEGORY' => 0, 'ESTIMATE' => 1, 'CONFIDENCE' => 2, 'GUESS_MIN' => 3, 'GUESS_MAX' => 4, 'RANGE' => 5 }

      categories = {}
      categories['Aerial or Ground Total Counts'.downcase] = 'A'
      categories['Direct Sample Counts and Reliable Dung Counts'.downcase] = 'B'
      categories['Other Dung Counts'.downcase] = 'C'
      categories['Informed Guesses'.downcase] = 'D'
      categories['Other guesses'.downcase] = 'E'
      categories['Data Degraded'.downcase] = 'F'
      categories['Modeled Extrapolation'.downcase] = 'G'

      @targets = { 'WA_NoRounding' => 'West_Africa', 'CA_NoRounding' => 'Central_Africa', 'EA_NoRounding' => 'Eastern_Africa' }
      @sheets  = []
      latest_analysis = AedUtils.latest_analysis

      @targets.each do |name, region|
        sheet = @xlsx.sheet_for name
        if sheet
          data = {}
          sheet.each_row(offset: sheet.first_row) do |row|
            if row[0]
              category = row[0].value.downcase rescue nil
              if categories[category]
                h = {}
                data_point_cols.each do |data_point, col|
                  h[data_point] = row[col].nil?? nil : row[col].value
                end
                data[categories[category]] = h
              end
            end
          end

          @sheets << { name: name, sheet: sheet, expected: data, actual: hash_tuples(execute(alt_dpps("region = '#{region.gsub('_',' ')}'", latest_analysis.analysis_year, latest_analysis.analysis_name))) }
        end
      end
    else
      redirect_to spreadsheets_path, alert: 'Spreadsheet not found, perhaps it has been deleted.'
    end
  end

  private

  def filename
    name = "#{params[:id]}.#{params[:format]}"
    if valid_filename? name
      return name
    else
      not_allowed!
    end
  end

  def valid_filename? name
    check = /^([a-zA-Z0-9()_-]+).?xlsx$/
    name =~ check
  end

  def directory
    File.join Rails.root, 'public', 'uploads', 'spreadsheets'
  end

  def ensure_admin!
    not_allowed! unless current_user.admin?
  end

  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def not_allowed!
    render(:file => File.join(Rails.root, 'public/500.html'), :status => 500, :layout => false)
  end

end
