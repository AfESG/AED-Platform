class ConfidenceChanges < ActiveRecord::Migration
  def change
    rename_column :survey_aerial_sample_count_strata, :population_confidence_limits, :population_confidence_interval
    add_column :survey_aerial_sample_count_strata, :population_lower_confidence_limit, :integer
    add_column :survey_aerial_sample_count_strata, :population_upper_confidence_limit, :integer

    rename_column :survey_aerial_total_count_strata, :population_confidence_limits, :population_confidence_interval
    add_column :survey_aerial_total_count_strata, :population_lower_confidence_limit, :integer
    add_column :survey_aerial_total_count_strata, :population_upper_confidence_limit, :integer

    rename_column :survey_dung_count_line_transect_strata, :population_confidence_limits, :population_confidence_interval
    rename_column :survey_dung_count_line_transect_strata, :asymmetric_upper_confidence_limit, :population_asymmetric_upper_confidence_interval
    rename_column :survey_dung_count_line_transect_strata, :asymmetric_lower_confidence_limit, :population_asymmetric_lower_confidence_interval
    add_column :survey_dung_count_line_transect_strata, :population_lower_confidence_limit, :integer
    add_column :survey_dung_count_line_transect_strata, :population_upper_confidence_limit, :integer

    rename_column :survey_dung_count_line_transect_strata, :dung_decay_rate_confidence_limits, :dung_decay_rate_confidence_interval
    add_column :survey_dung_count_line_transect_strata, :dung_decay_rate_lower_confidence_limit, :float
    add_column :survey_dung_count_line_transect_strata, :dung_decay_rate_upper_confidence_limit, :float

    rename_column :survey_dung_count_line_transect_strata, :defecation_rate_confidence_limits, :defecation_rate_confidence_interval
    add_column :survey_dung_count_line_transect_strata, :defecation_rate_lower_confidence_limit, :float
    add_column :survey_dung_count_line_transect_strata, :defecation_rate_upper_confidence_limit, :float

    rename_column :survey_dung_count_line_transect_strata, :dung_density_confidence_limits, :dung_density_confidence_interval
    add_column :survey_dung_count_line_transect_strata, :dung_density_lower_confidence_limit, :float
    add_column :survey_dung_count_line_transect_strata, :dung_density_upper_confidence_limit, :float
    rename_column :survey_dung_count_line_transect_strata, :dung_density_asymmetric_upper_confidence_limit, :dung_density_asymmetric_upper_confidence_interval
    rename_column :survey_dung_count_line_transect_strata, :dung_density_asymmetric_lower_confidence_limit, :dung_density_asymmetric_lower_confidence_interval


    rename_column :survey_faecal_dna_strata, :population_confidence_limits, :population_confidence_interval
    add_column :survey_faecal_dna_strata, :population_lower_confidence_limit, :integer
    add_column :survey_faecal_dna_strata, :population_upper_confidence_limit, :integer

    rename_column :survey_ground_sample_count_strata, :population_confidence_limits, :population_confidence_interval
    add_column :survey_ground_sample_count_strata, :population_lower_confidence_limit, :integer
    add_column :survey_ground_sample_count_strata, :population_upper_confidence_limit, :integer

    rename_column :survey_ground_total_count_strata, :population_confidence_limits, :population_confidence_interval
    add_column :survey_ground_total_count_strata, :population_lower_confidence_limit, :integer
    add_column :survey_ground_total_count_strata, :population_upper_confidence_limit, :integer
  end
end
