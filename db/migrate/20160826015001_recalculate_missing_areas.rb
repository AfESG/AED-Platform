class RecalculateMissingAreas < ActiveRecord::Migration
  def p_execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end

  def up
    tables = [
      'survey_aerial_sample_count_strata',
      'survey_aerial_total_count_strata',
      'survey_ground_sample_count_strata',
      'survey_ground_total_count_strata',
      'survey_dung_count_line_transect_strata',
      'survey_faecal_dna_strata',
      'survey_individual_registrations',
      'survey_others'
    ]
    tables.each do |table|
      puts "Populating missing areas for #{table}"
      result = p_execute <<-SQL
        update #{table} s
        set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
        from survey_geometries sg
        where
        sg.id = s.survey_geometry_id
        and (s.stratum_area is null
          or s.stratum_area < 1)
        ;
      SQL
    end
    PopulationSubmission.order(:id).each do |population_submission|
      if population_submission.area and population_submission.area > 1
        puts "Keeping existing area: #{population_submission.area}"
      else
        puts "Need to calculate area"
        count = population_submission.counts[0]
        if count
          if count.has_strata?
            puts "  Count has strata"
            area = 0
            count.strata.each do |stratum|
              if stratum.stratum_area and stratum.stratum_area > 1
                area = area + stratum.stratum_area
              else
                puts "    But stratum #{stratum.id} still has no area"
              end
            end
            if area > 0
              puts "   Derived area: #{area}"
              population_submission.area = area
              population_submission.save!
            end
          else
            puts "  Count has no strata"
            if count.stratum_area and count.stratum_area > 1
              puts "   Derived area: #{count.stratum_area}"
              population_submission.area = count.stratum_area
              population_submission.save!
            else
                puts "    But count #{count.id} still has no area"
            end
          end
        end
      end
    end
  end
end
