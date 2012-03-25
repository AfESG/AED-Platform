class AddCarcassUnknown < ActiveRecord::Migration
  def change
    add_column :survey_aerial_sample_count_strata, :carcasses_age_unknown, :integer
    add_column :survey_aerial_total_count_strata, :carcasses_age_unknown, :integer
  end
end
