class WelcomeController < ApplicationController

  def index
  end

  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  helper_method :enumerate_oids, :enumerate_strata

  def enumerate_oids(oid_csv)
    oids = execute <<-SQL
      SELECT * FROM aed2007."Surveydata" WHERE "OBJECTID" IN (#{oid_csv})
    SQL
    divs = []
    oids.each do |oid|
      divs << "<div><a href='/find/2007/#{oid["OBJECTID"]}'>#{oid["SURVEYZONE"]} #{oid["DESIGNATE"]}</a>: #{oid["ESTIMATE"]}</div>"
    end
    divs.join ''
  end

  def enumerate_strata(strata_csv)
    strata = strata_csv.split(',')
    nstrata = []
    strata.each do |stratum|
      nstrata << "'#{stratum}'"
    end
    begin
      ests = execute <<-SQL
        SELECT * FROM estimates WHERE input_zone_id IN (#{nstrata.join(',')})
      SQL
      divs = []
      ests.each do |est|
        divs << "<div><a href='/population_submissions/#{est['population_submission_id']}'>#{est['stratum_name']}</a>: #{est['population_estimate']}</div>"
      end
      return divs.join ''
    rescue
      return 'No new data available'
    end
  end

  before_filter :authenticate_user!, :only => :mike_report

  def mike_report
    return unless current_user.admin?
    @changes = execute <<-SQL
      SELECT *
      FROM replacement_map
      order by "mike_site"
    SQL
  end

  # This simulates an uncaught exception for testing
  def crash
    raise Exception
  end

  def recalc
    return unless current_user.admin?
    execute <<-SQL
      begin;

      delete from dpps_sums_continent_category;
      insert into dpps_sums_continent_category
      select * from i_dpps_sums_continent_category;

      delete from dpps_sums_continent_category_reason;
      insert into dpps_sums_continent_category_reason
      select * from i_dpps_sums_continent_category_reason;

      delete from dpps_sums_region_category;
      insert into dpps_sums_region_category
      select * from i_dpps_sums_region_category;

      delete from dpps_sums_region_category_reason;
      insert into dpps_sums_region_category_reason
      select * from i_dpps_sums_region_category_reason;

      delete from dpps_sums_country_category;
      insert into dpps_sums_country_category
      select * from i_dpps_sums_country_category;

      delete from dpps_sums_country_category_reason;
      insert into dpps_sums_country_category_reason
      select * from i_dpps_sums_country_category_reason;

      commit;
    SQL
    render :text => 'Change interpreters recalculated.'
  end

end
