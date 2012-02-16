class IndividualRegistrationFencing < ActiveRecord::Migration
  def change
    change_column :survey_individual_registrations, :fenced_site, :string
    add_column :survey_individual_registrations, :porous_fenced_site, :string
  end
end
