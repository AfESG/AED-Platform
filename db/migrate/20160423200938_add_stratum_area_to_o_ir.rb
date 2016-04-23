class AddStratumAreaToOIr < ActiveRecord::Migration
  def change
    add_column :survey_others, :stratum_area, :integer
    add_column :survey_individual_registrations, :stratum_area, :integer
  end
end
