class CreateRangeStates < ActiveRecord::Migration
  def up
    create_table :species_range_state_countries do |t|
      t.integer :species_id
      t.integer :country_id

      t.timestamps
    end
    loxodonta_africana = Species.find :first, :conditions => {:scientific_name => 'Loxodonta africana'}
    old_range_states = ActiveRecord::Base.connection.execute <<-SQL
      SELECT "CCODE" FROM aed2007."Country" where "RangeState"=1
    SQL
    old_range_states.each do |old_range_state|
      country = Country.find :first, :conditions => {:iso_code => old_range_state['CCODE'] }
      puts "  -- #{country.name} is #{loxodonta_africana.common_name} range"
      loxodonta_africana.range_states << country
    end
    loxodonta_africana.save
  end
  def down
    drop_table :species_range_state_countries
  end
end
