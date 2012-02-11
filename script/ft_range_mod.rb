require 'fusion_tables'
require 'geo_ruby'
include GeoRuby
include SimpleFeatures

ft = GData::Client::FusionTables.new
ft.clientlogin('rob.heittman@solertium.com',ENV['FT_PASSWORD'])
@range_table = ft.show_tables.select{|t| t.name == '2007 AESR African Elephant Range'}.first

current = @range_table.select "ROWID,Range,RangeQuali"

current.each do |row|
  i = row[:rowid]
  puts row
  if row[:range]=='1' and row[:rangequali]=='Known'
    @range_table.update i, {"description" => "#007700"}
  elsif row[:range]=='1' and row[:rangequali]=='Possible'
    @range_table.update i, {"description" => "#00ff00"}
  else
    @range_table.update i, {"description" => "#cccccc"}
  end
end
