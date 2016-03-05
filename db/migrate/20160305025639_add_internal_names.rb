class AddInternalNames < ActiveRecord::Migration
  def change
    add_column :population_submissions, :internal_name, :string
    add_column :survey_aerial_sample_count_strata, :internal_name, :string
    add_column :survey_aerial_total_count_strata, :internal_name, :string
    add_column :survey_faecal_dna_strata, :internal_name, :string
    add_column :survey_ground_sample_count_strata, :internal_name, :string
    add_column :survey_ground_total_count_strata, :internal_name, :string
    add_column :survey_dung_count_line_transect_strata, :internal_name, :string
  end
end
