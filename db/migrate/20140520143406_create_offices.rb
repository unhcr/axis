class CreateOffices < ActiveRecord::Migration
  def up
    create_table :offices, :id => false do |t|
      t.string :id, :null => false
      t.string :name
      t.string :head_office_id
      t.boolean :head
      t.datetime :found_at
      t.string :operation_id
      t.string :plan_id

      t.timestamps
    end
    add_index :offices, :id, :unique => true
  end

  def down
    remove_index :offices
    drop_table :offices
  end
end
