class SupportInformedGuesses < ActiveRecord::Migration
  def change
    add_column :survey_others, :actually_seen, :integer
    add_column :survey_others, :informed, :boolean
  end
end
