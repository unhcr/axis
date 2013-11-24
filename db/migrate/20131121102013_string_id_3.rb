class StringId3 < ActiveRecord::Migration
  def change
    drop_table :operations

    create_table :operations, :id => false do |t|
      t.string :id, :null => false
      t.string :name
      t.text :years

      t.timestamps
    end
    add_index :operations, :id, :unique => true
  end
end
