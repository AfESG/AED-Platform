class ChangeDungCountFieldsToFloats < ActiveRecord::Migration
  def up
    change_column :survey_dung_count_line_transect_strata, :transects_covered_total_length, :float
    change_column :survey_dung_count_line_transect_strata, :dung_decay_rate_estimate_used, :float
    change_column :survey_dung_count_line_transect_strata, :defecation_rate_estimate_used, :float
    change_column :survey_dung_count_line_transect_strata, :dung_encounter_rate, :float
  end
end
