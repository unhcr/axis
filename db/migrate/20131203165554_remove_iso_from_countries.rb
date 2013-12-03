class RemoveIsoFromCountries < ActiveRecord::Migration
  def up
    remove_column :countries, :iso
  end

  def down
    add_column :countries, :iso, :string
  end
end
