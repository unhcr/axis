class StringId2 < ActiveRecord::Migration
  def change
    change_table :operations, :id => false do |t|
    end
    change_column :operations, :id, :string, :null => false
    add_index :operations, :id, :unique => true
  end
end
