class SubmissionSearchController < ApplicationController

  # FIXME: this is repeated from report_controller
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def index
    if params[:country] and !params[:country].blank?
      if user_signed_in? && current_user.admin?
        @search_results = execute <<-SQL
          SELECT  distinct (e.population_submission_id), ps.site_name, ps.survey_type, ps.short_citation, sum(population_estimate) as estimate, released,  data_licensing, u.name
          FROM population_submissions ps
          join submissions sub on ps. submission_id = sub.id
          join countries c on c.id= sub.country_id
          join users u on u.id = sub.user_id
          join estimate_factors_analyses e on e.population_submission_id = ps.id
          WHERE ps.completion_year=#{params[:survey_year]}
          AND c.id= #{params[:country]}
          AND released=#{params[:released]}
          GROUP BY e.population_submission_id, ps.site_name, ps.survey_type , ps.short_citation, released,  data_licensing, u.name
          ORDER BY  ps.site_name;
          SQL
      else
        @search_results = execute <<-SQL
          SELECT  distinct (e.population_submission_id), ps.site_name, ps.survey_type, ps.short_citation, sum(population_estimate) as estimate, released,  data_licensing, u.name
          FROM population_submissions ps
          join submissions sub on ps. submission_id = sub.id
          join countries c on c.id= sub.country_id
          join users u on u.id = sub.user_id
          join estimate_factors_analyses e on e.population_submission_id = ps.id
          WHERE ps.completion_year=#{params[:survey_year]}
          AND c.id=#{params[:country]}
          AND released=true
          GROUP BY e.population_submission_id, ps.site_name, ps.survey_type , ps.short_citation, released,  data_licensing, u.name
          ORDER BY  ps.site_name;
          SQL
      end
    end
  end
end
