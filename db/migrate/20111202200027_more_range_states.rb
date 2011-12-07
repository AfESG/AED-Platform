class MoreRangeStates < ActiveRecord::Migration
  def up
    loxodonta_africana = Species.find :first, :conditions => {:scientific_name => 'Loxodonta africana'}
    country = Country.find :first, :conditions => {:iso_code => 'SD'}
    puts "  -- #{country.name} is NOT #{loxodonta_africana.common_name} range"
    loxodonta_africana.range_states.delete(country)
    loxodonta_africana.save

    elephas_maximus = Species.find :first, :conditions => {:scientific_name => 'Elephas maximus'}
    # add asian countries
    asia = { 'IN' => 'India',
      'BD' => 'Bangladesh',
      'NP' => 'Nepal',
      'BT' => 'Bhutan',
      'LK' => 'Sri Lanka',
      'ID' => 'Indonesia',
      'MY' => 'Malaysia',
      'TH' => 'Thailand',
      'MM' => 'Myanmar',
      'CN' => 'China',
      'LA' => 'Laos',
      'VN' => 'Vietnam',
      'KH' => 'Cambodia' }
    asia.each do |iso_code,name|
      country = Country.new
      country.iso_code = iso_code
      country.name = name
      puts "  -- Creating #{country.name}"
      country.save
      elephas_maximus.range_states << country
      puts "  -- Setting #{country.name} as #{elephas_maximus.common_name} range"
    end
    elephas_maximus.save
  end

  def down
  end
end
