class AddSurveyGeometryAttribution < ActiveRecord::Migration
  def up
    add_column :survey_geometries, :attribution, :string
    PopulationSubmission.order(:id).each do |population_submission|
      if population_submission.counts.count > 0
        population_submission.counts[0].strata.each do |stratum|
          if stratum.survey_geometry
            stratum.survey_geometry.attribution = population_submission.short_citation
            puts "Geometry #{stratum.survey_geometry.id} attributed to #{population_submission.short_citation}"
            stratum.survey_geometry.save!
          end
        end
      end
    end
  end

  def down
    remove_column :survey_geometries, :attribution
  end
end
