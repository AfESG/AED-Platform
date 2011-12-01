class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :scientific_name
      t.string :common_name

      t.timestamps
    end

    loxodonta_africana = Species.new
    puts "  -- Adding Loxodonta africana"
    loxodonta_africana.scientific_name = 'Loxodonta africana'
    loxodonta_africana.common_name = 'African Elephant'
    loxodonta_africana.save

    elephas_maximus = Species.new
    puts "  -- Adding Elephas maximus"
    elephas_maximus.scientific_name = 'Elephas maximus'
    elephas_maximus.common_name= 'Asian Elephant'
    elephas_maximus.save
  end
end
