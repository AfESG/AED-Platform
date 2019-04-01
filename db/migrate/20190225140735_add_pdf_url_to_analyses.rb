class AddPdfUrlToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :pdf_url, :string, null: true

    Analysis.find_by(analysis_year: 2015)&.update_attribute(:pdf_url, 'https://www.dropbox.com/s/dl/7a8w3kk6r9hzm0r/AfESG 20African 20Elephant 20Status 20Report 202016.pdf')
  end
end
