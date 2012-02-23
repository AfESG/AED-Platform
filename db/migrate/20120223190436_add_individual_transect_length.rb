class AddIndividualTransectLength < ActiveRecord::Migration
  def change
    add_column :survey_dung_count_line_transect_strata, :individual_transect_length, :float
    add_column :survey_ground_sample_count_strata, :individual_transect_length, :float
  end
end
