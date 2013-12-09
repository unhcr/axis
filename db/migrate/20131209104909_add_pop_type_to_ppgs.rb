class AddPopTypeToPpgs < ActiveRecord::Migration
  def change
    add_column :ppgs, :population_type, :string
    add_column :ppgs, :population_type_id, :string
  end
end
