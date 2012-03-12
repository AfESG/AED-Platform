class AddAsymmetricDungDensity < ActiveRecord::Migration
  def change
    add_column :survey_dung_count_line_transect_strata, :dung_density_asymmetric_upper_confidence_limit, :integer
    add_column :survey_dung_count_line_transect_strata, :dung_density_asymmetric_lower_confidence_limit, :integer
  end
end
