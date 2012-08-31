class CreateSurveyGeometryIds < ActiveRecord::Migration
  def change
    add_column :survey_aerial_sample_count_strata, :survey_geometry_id, :integer
    add_column :survey_aerial_total_count_strata, :survey_geometry_id, :integer
    add_column :survey_dung_count_line_transect_strata, :survey_geometry_id, :integer
    add_column :survey_faecal_dna_strata, :survey_geometry_id, :integer
    add_column :survey_ground_sample_count_strata, :survey_geometry_id, :integer
    add_column :survey_ground_total_count_strata, :survey_geometry_id, :integer
    add_column :survey_individual_registrations, :survey_geometry_id, :integer
    add_column :survey_others, :survey_geometry_id, :integer
  end
end
