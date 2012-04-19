MikeSite.destroy_all
ActiveRecord::Base.connection.execute "select setval('mike_sites_id_seq',1);"
CSV.foreach("script/etl/mikesites.csv") do |row|
  site = MikeSite.new
  site.subregion = row[0]
  site.country_id = Country.where(:iso_code => row[1].upcase).first.id
  site.site_code = row[2]
  site.site_name = row[3]
  site.area = row[4]
  site.save
end
