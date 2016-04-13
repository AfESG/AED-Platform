class PopulateCentroids < ActiveRecord::Migration
  def up
    PopulationSubmission.order(:id).each do |population_submission|
      if population_submission.latitude or population_submission.longitude
        puts "Keeping existing coordinate: #{population_submission.latitude}, #{population_submission.longitude}"
      else
        puts "Need to calculate coordinate"
        count = population_submission.counts[0]
        if count
          if count.has_strata?
            puts "  Count has strata"
            lat_agg = 0
            long_agg = 0
            n = 0
            count.strata.each do |stratum|
              survey_geometry = stratum.survey_geometry
              if survey_geometry and survey_geometry.geom
                puts "   Stratum long: #{survey_geometry.geom.centroid.x}"
                long_agg = long_agg + survey_geometry.geom.centroid.x
                puts "   Stratum lat: #{survey_geometry.geom.centroid.y}"
                lat_agg = lat_agg + survey_geometry.geom.centroid.y
                n = n + 1
              else
                puts "  Stratum has no geometry, staying empty"
              end
            end
            if n > 0
              long = long_agg / n
              lat = lat_agg / n
              puts "   Derived long: #{long}"
              puts "   Derived lat: #{lat}"
              population_submission.latitude = lat
              population_submission.longitude = long
              population_submission.save!
            end
          else
            puts "  Count has no strata"
            survey_geometry = count.survey_geometry
            if survey_geometry and survey_geometry.geom
              puts "   Derived long: #{survey_geometry.geom.centroid.x}"
              puts "   Derived lat: #{survey_geometry.geom.centroid.y}"
              population_submission.latitude = survey_geometry.geom.centroid.y
              population_submission.longitude = survey_geometry.geom.centroid.x
              population_submission.save!
            else
              puts "  Count has no geometry, staying empty"
            end
          end
        end
      end
    end
  end
end
