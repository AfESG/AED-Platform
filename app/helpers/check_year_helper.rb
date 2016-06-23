module CheckYearHelper
  def check_year!
    if Analysis::YEARS.include?(action_name.to_sym)
      valid_years = Analysis::YEARS[action_name.to_sym]
      render json: { data: nil } unless valid_years.include?(params[:year].to_i)
    end
  end
end
