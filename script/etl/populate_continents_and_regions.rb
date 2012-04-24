Continent.destroy_all
ActiveRecord::Base.connection.execute "select setval('continents_id_seq',1);"

puts 'Creating Africa'
africa = Continent.new
africa.name='Africa'
africa.save!

puts 'Creating Asia'
asia = Continent.new
asia.name='Asia'
asia.save!

Region.destroy_all
ActiveRecord::Base.connection.execute "select setval('regions_id_seq',1);"

regions_2007 = ActiveRecord::Base.connection.execute 'select * from aed2007."Regions"'
regions_2007.each do |source_region|
  region = Region.new
  region.continent = africa
  region.name = source_region['REGION']
  puts "Creating region #{region.name}"
  region.save!
  countries_2007 = ActiveRecord::Base.connection.execute "select * from aed2007.\"Country\" where \"REGION\"='#{region.name}'"
  countries_2007.each do |source_country|
    country = Country.where(:iso_code => source_country['CCODE']).first()
    unless country.nil?
      puts "  Linking #{country.name} to this region"
      country.region = region
      country.save!
    end
  end
end

