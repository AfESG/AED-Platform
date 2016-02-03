class More2007Geometries < ActiveRecord::Migration

  def p_execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def up
    mappings={
      'AS' => 'SurveyAerialSampleCountStratum',
      'AT' => 'SurveyAerialTotalCountStratum',
      'DC' => 'SurveyDungCountLineTransectStratum',
      'GD' => 'SurveyFaecalDnaStratum',
      'GS' => 'SurveyGroundSampleCountStratum',
      'GT' => 'SurveyGroundTotalCountStratum',
      'IR' => 'SurveyIndividualRegistration',
      'O' => 'SurveyOther'
    }
    puts "You need a 2007 GIS dump for this migration to be effective."
    puts "Iterating through 2013_africa_final analysis"
    Change.where(analysis_name: '2013_africa_final').each do |change|
      if change.replaced_strata and !(change.replaced_strata.blank?) and !(change.replaced_strata == '-')
        change.replaced_strata.split(/,\s*/).each do |stratum_code|
          stratum_key = stratum_code.gsub(/\d*/,'')
          stratum_class = eval mappings[stratum_key]
          stratum_id = stratum_code.gsub(/[^\d]*/,'').to_i
          stratum = stratum_class.find stratum_id
          if stratum
            unless stratum.survey_geometry
              puts "#{stratum_key} #{stratum_class} #{stratum_id} has no survey geometry"
              ps = nil
              if defined? stratum.population_submission
                ps = stratum.population_submission
              else
                ps = stratum.parent_count.population_submission
              end
              completion_year = ps.completion_year
              iso_code = ps.submission.country.iso_code
              survey_zone = ps.site_name.strip
              designate = ps.designate
              designate = designate.strip if designate
              short_citation = ps.short_citation.strip
              puts "  --- Looking up #{iso_code},#{completion_year},#{survey_zone},#{designate},#{short_citation} in old GIS data"
              result = nil
              if designate
                result = p_execute <<-SQL, iso_code, completion_year, survey_zone, designate, short_citation
                  select geom from julian_2007
                    where ccode=?
                    and cyear=?
                    and TRIM(both ' ' from surveyzone)=?
                    and designate=?
                    and TRIM(both ' ' from reference)=?
                SQL
              else
                result = p_execute <<-SQL, iso_code, completion_year, survey_zone, short_citation
                  select geom from julian_2007
                    where ccode=?
                    and cyear=?
                    and TRIM(both ' ' from surveyzone)=?
                    and TRIM(both ' ' from reference)=?
                SQL
              end
              if result.count > 0
                puts "  +++ Creating new SurveyGeometry from old data"
                sg = SurveyGeometry.create(geom: result[0]['geom'])
                sg.save!
                puts "  +++ Linking stratum"
                stratum.survey_geometry = sg
                stratum.save! :validate => false
              else
                puts "  !!! Nothing found still"
              end
            end
          else
            puts "  !!! That stratum doesn't exist"
          end
        end
      end
    end
  end

  def down
  end

end
