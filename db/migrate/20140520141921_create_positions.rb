class CreatePositions < ActiveRecord::Migration
  def up
    create_table :positions, :id => false do |t|
      t.string :id, :null => false
      t.string :position_reference
      t.string :contractType
      t.string :incumbent
      t.string :title
      t.string :grade
      t.boolean :head
      t.boolean :fast_track
      t.string :head_position_id
      t.string :operation_id
      t.string :plan_id
      t.datetime :found_at

      t.timestamps
    end

    add_index :positions, :id, :unique => true
  end

  def down
    remove_index :positions
    drop_table :positions
  end

end
