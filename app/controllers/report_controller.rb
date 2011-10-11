class ReportController < ApplicationController

  def country
    @year = params[:year]
    @continent = params[:continent]
    @region = params[:region].gsub('_',' ')
    @country = params[:country].gsub('_',' ')

    @causes_of_change_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.causes_of_change_by_country where ccode='#{@country}'
    SQL

    @summary_totals_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.summary_totals_by_country where ccode='#{@country}'
    SQL

    @summary_sums_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.summary_sums_by_country where ccode='#{@country}'
    SQL

    @area_of_range_covered_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.area_of_range_covered_by_country where ccode='#{@country}'
    SQL

    @area_of_range_covered_sum_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.area_of_range_covered_sum_by_country where ccode='#{@country}'
    SQL

    @elephant_estimates_by_country = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.elephant_estimates_by_country where ccode='#{@country}'
    SQL

  end

end
