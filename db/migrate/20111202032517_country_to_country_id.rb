class CountryToCountryId < ActiveRecord::Migration
  def up
    rename_column :submissions, :country, :country_id
    ActiveRecord::Base.connection.execute <<-SQL
      update submissions set country_id=c.id
      from countries c
      where submissions.country_id = c.name;
    SQL
  end

  def down
    rename_column :submissions, :country_id, :country
  end
end
