class DescriptiveFieldsForAttachments < ActiveRecord::Migration
  def change
    add_column :population_submission_attachments, :attachment_type, :text
    add_column :population_submission_attachments, :restrict, :boolean
  end
end
