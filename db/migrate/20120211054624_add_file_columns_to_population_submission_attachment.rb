class AddFileColumnsToPopulationSubmissionAttachment < ActiveRecord::Migration
  def change
    change_table :population_submission_attachments do |t|
      t.has_attached_file :file
    end
  end
end
