class SubmissionSearchController < ApplicationController

  # FIXME: this is repeated from report_controller
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def index
    # TODO: make :country work with some joins
    if params[:country] and !params[:country].blank?
      @search_results = execute <<-SQL
        SELECT *
        FROM population_submissions
        WHERE completion_year=#{params[:survey_year]}
          AND released=#{params[:released]}
        LIMIT 10
      SQL
    end
  end
end
