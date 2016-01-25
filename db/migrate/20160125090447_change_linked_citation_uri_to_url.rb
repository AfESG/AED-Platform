class ChangeLinkedCitationUriToUrl < ActiveRecord::Migration
  def change
    rename_column :linked_citations, :uri, :url
  end
end
