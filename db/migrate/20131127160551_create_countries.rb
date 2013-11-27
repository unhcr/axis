class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso
      t.text :latlng
      t.string :iso3
      t.string :iso2
      t.string :region
      t.string :subregion
      t.text :un_names
      t.string :name

      t.timestamps
    end
  end
end
