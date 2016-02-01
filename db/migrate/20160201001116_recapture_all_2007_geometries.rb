class RecaptureAll2007Geometries < ActiveRecord::Migration
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
        puts "Examining #{change.replaced_strata}"
        change.replaced_strata.split(/,\s*/).each do |stratum_code|
          stratum_key = stratum_code.gsub(/\d*/,'')
          stratum_class = eval mappings[stratum_key]
          stratum_id = stratum_code.gsub(/[^\d]*/,'').to_i
          puts "Finding #{stratum_key} #{stratum_class} #{stratum_id}"
          stratum = stratum_class.find stratum_id
          if stratum
            if stratum.survey_geometry
              puts "  +++ It has an existing survey_geometry"
            else
              puts "  --- It has no survey geometry"
            end
            ps = nil
            if defined? stratum.population_submission
              ps = stratum.population_submission
            else
              ps = stratum.parent_count.population_submission
            end
            short_citation = ps.short_citation
            completion_year = ps.completion_year
            iso_code = ps.submission.country.iso_code
            survey_zone = ps.site_name
            designate = ps.designate
            puts "  --- Looking up #{iso_code},#{completion_year},#{survey_zone} #{designate},#{short_citation} in old GIS data"
            result = p_execute <<-SQL, iso_code, completion_year, survey_zone, designate, short_citation
              select geom from julian_2007
                where ccode=?
                and cyear=?
                and surveyzone=?
                and designate=?
                and reference=?
            SQL
            if result.count > 0
              puts "  +++ Creating new SurveyGeometry from old data"
              sg = SurveyGeometry.create(geom: result[0]['geom'])
              sg.save!
              puts "  +++ Linking stratum"
              stratum.survey_geometry = sg
              stratum.save! :validate => false
            else
              puts "  !!! Nothing found, unlinking stratum"
              stratum.survey_geometry = nil
              stratum.save! :validate => false
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
