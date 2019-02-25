class AddPdfUrlToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :pdf_url, :string, null: true

    Analysis.find_by(analysis_year: 2015)&.update_attribute(:pdf_url, 'https://portals.iucn.org/library/sites/library/files/documents/SSC-OP-060_A.pdf')
  end
end
