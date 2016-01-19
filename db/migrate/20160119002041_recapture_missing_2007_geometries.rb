class RecaptureMissing2007Geometries < ActiveRecord::Migration
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
              puts "  +++ Good, it has a survey_geometry"
            else
              puts "  --- It has no survey geometry"
              short_citation = nil
              if defined? stratum.population_submission
                short_citation = stratum.population_submission.short_citation
              else
                short_citation = stratum.parent_count.population_submission.short_citation
              end
              puts "  --- Looking up #{short_citation} in old GIS data"
              result = execute <<-SQL
                select geom from julian_2007
                  where reference='#{short_citation}';
              SQL
              if result.count > 0
                puts "  +++ Creating new SurveyGeometry from old data"
                sg = SurveyGeometry.create(geom: result[0]['geom'])
                sg.save!
                puts "  +++ Linking stratum"
                stratum.survey_geometry = sg
                stratum.save! :validate => false
              else
                puts "  !!! Nothing found"
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
