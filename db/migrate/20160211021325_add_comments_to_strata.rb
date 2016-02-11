class AddCommentsToStrata < ActiveRecord::Migration
  def change
    add_column :survey_aerial_total_count_strata, :comments, :text
    add_column :survey_aerial_sample_count_strata, :comments, :text
    add_column :survey_ground_total_count_strata, :comments, :text
    add_column :survey_ground_sample_count_strata, :comments, :text
    add_column :survey_dung_count_line_transect_strata, :comments, :text
    add_column :survey_faecal_dna_strata, :comments, :text
  end
end
