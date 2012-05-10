class MoveMikeSiteFields < ActiveRecord::Migration
  def change
    add_column :survey_aerial_sample_count_strata, :mike_site_id, :integer
    add_column :survey_aerial_sample_count_strata, :is_mike_site, :boolean

    add_column :survey_aerial_total_count_strata, :mike_site_id, :integer
    add_column :survey_aerial_total_count_strata, :is_mike_site, :boolean

    add_column :survey_dung_count_line_transect_strata, :mike_site_id, :integer
    add_column :survey_dung_count_line_transect_strata, :is_mike_site, :boolean

    add_column :survey_faecal_dna_strata, :mike_site_id, :integer
    add_column :survey_faecal_dna_strata, :is_mike_site, :boolean

    add_column :survey_ground_sample_count_strata, :mike_site_id, :integer
    add_column :survey_ground_sample_count_strata, :is_mike_site, :boolean

    add_column :survey_ground_total_count_strata, :mike_site_id, :integer
    add_column :survey_ground_total_count_strata, :is_mike_site, :boolean

    add_column :survey_individual_registrations, :mike_site_id, :integer
    add_column :survey_individual_registrations, :is_mike_site, :boolean

    add_column :survey_others, :mike_site_id, :integer
    add_column :survey_others, :is_mike_site, :boolean
  end
end
