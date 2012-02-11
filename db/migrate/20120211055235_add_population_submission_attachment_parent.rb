class AddPopulationSubmissionAttachmentParent < ActiveRecord::Migration
  def change
    add_column :population_submission_attachments, :population_submission_id, :integer
  end
end
