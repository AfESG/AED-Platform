class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.string :iso_code
      t.string :name
      t.timestamps
    end
    old_countries = ActiveRecord::Base.connection.execute <<-SQL
      SELECT "CCODE", "CNTRYNAME" FROM aed2007."Country"
    SQL
    old_countries.each do |old_country|
      new_country = Country.new
      puts "  -- Migrating #{old_country['CNTRYNAME']}"
      new_country.iso_code = old_country['CCODE']
      new_country.name = old_country['CNTRYNAME']
      new_country.save
    end
    south_sudan = Country.new
    puts "  -- Adding South Sudan"
    south_sudan.iso_code = 'SS'
    south_sudan.name = 'South Sudan'
    south_sudan.save
  end
  def down
    drop_table :countries
  end
end
