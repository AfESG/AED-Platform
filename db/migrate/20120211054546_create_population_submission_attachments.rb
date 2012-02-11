class CreatePopulationSubmissionAttachments < ActiveRecord::Migration
  def change
    create_table :population_submission_attachments do |t|
      t.timestamps
    end
  end
end
