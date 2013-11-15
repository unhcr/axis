class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :id
      t.string :name
      t.text :years

      t.timestamps
    end
  end
end
