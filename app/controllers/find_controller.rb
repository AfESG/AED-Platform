class FindController < ApplicationController

  def historical
    @species = 'Loxodonta_africana'
    @continent = 'Africa'
    @year = params[:year]
    @inpcode = params[:inpcode]
    survey_zones = ActiveRecord::Base.connection.execute <<-SQL
      SELECT *
      FROM aed#{@year}.elephant_estimates_by_country where "INPCODE"='#{@inpcode}'
    SQL
    survey_zones.each do |survey_zone|
      countries = ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM aed#{@year}."Country" where "CCODE"='#{survey_zone['ccode']}'
      SQL
      countries.each do |country|
        @country = country['CNTRYNAME']
        regions = ActiveRecord::Base.connection.execute <<-SQL
          SELECT * FROM aed#{@year}."Regions" where "REGIONID"='#{country['REGIONID']}'
        SQL
        regions.each do |region|
          @region = region['REGION'].gsub(' ','_')
          break
        end
        break
      end
      break
    end
    render :layout => 'internal'
  end

end
