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
    return if current_user.nil?
    return unless current_user.admin?
    if defined? $RECALC_RUNNING and $RECALC_RUNNING == true
      render :text => 'A recalculation may already be running. Please wait a bit before trying again.'
      return
    end
    Thread.new {
      logger.info("Recalc started")
      $RECALC_RUNNING = true
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
      $RECALC_RUNNING = false
      logger.info("Recalc finished")
    }
    render :text => 'Change interpreters recalculating in background. Please wait at least 2 minutes before running this again.'
  end

end
