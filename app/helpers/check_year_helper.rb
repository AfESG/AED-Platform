module CheckYearHelper
  def check_year!
    if Analysis.years.include?(action_name.to_sym)
      valid_years = Analysis.years[action_name.to_sym]
      render json: { data: nil } unless valid_years.include?(params[:year].to_i)
    end
  end
end
