class SudanIsAfricanRangeState < ActiveRecord::Migration
  def up
    loxodonta_africana = Species.find :first, :conditions => {:scientific_name => 'Loxodonta africana'}
    country = Country.find :first, :conditions => {:iso_code => 'SS'}
    puts "  -- #{country.name} is #{loxodonta_africana.common_name} range"
    loxodonta_africana.range_states << country
    loxodonta_africana.save
  end

  def down
  end
end
