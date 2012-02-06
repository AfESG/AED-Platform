class CreateReportNarratives < ActiveRecord::Migration
  def change
    create_table :report_narratives do |t|
      t.string :uri
      t.text :narrative
      t.text :footnote

      t.timestamps
    end
  end
end
