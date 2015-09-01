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
          SELECT  distinct (e.population_submission_id), e.site_name, ps.survey_type, ps.short_citation, sum(population_estimate) as estimate, released,  data_licensing, u.name
          FROM population_submissions ps
          join submissions sub on ps. submission_id = sub.id
          join countries c on c.id= sub.country_id
          join users u on u.id = sub.user_id
          join estimate_factors_analyses e on e.population_submission_id = ps.id
          WHERE ps.completion_year=#{params[:survey_year]}
          AND c.id= #{params[:country]}
          AND released=#{params[:released]}
          GROUP BY e.population_submission_id, e.site_name, ps.survey_type , ps.short_citation, released,  data_licensing, u.name
          ORDER BY  e.site_name;
          SQL
      else
        @search_results = execute <<-SQL
          SELECT  distinct (e.population_submission_id), e.site_name, ps.survey_type, ps.short_citation, sum(population_estimate) as estimate, released,  data_licensing, u.name
          FROM population_submissions ps
          join submissions sub on ps. submission_id = sub.id
          join countries c on c.id= sub.country_id
          join users u on u.id = sub.user_id
          join estimate_factors_analyses e on e.population_submission_id = ps.id
          WHERE ps.completion_year=#{params[:survey_year]}
          AND c.id=#{params[:country]}
          AND released=true
          GROUP BY e.population_submission_id, e.site_name, ps.survey_type , ps.short_citation, released,  data_licensing, u.name
          ORDER BY  e.site_name;
          SQL
      end
    end
    render layout: 'bootstrapped'
  end
end
#@population_submissions = PopulationSubmission.joins(:submission).joins('join countries on submissions.country_id=countries.id').where("population_submissions.id in (select population_submission_id from estimate_factors_analyses where analysis_name='2013_africa_final')").order(translated_sort_column + ' ' + sort_direction);
