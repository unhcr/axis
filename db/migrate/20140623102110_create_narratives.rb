class CreateNarratives < ActiveRecord::Migration
  def up
    create_table :narratives, :id => false do |t|
      t.string :id, :null => false
      t.datetime :found_at
      t.string :operation_id
      t.string :plan_id
      t.string :goal_id
      t.string :ppg_id
      t.string :problem_objective_id
      t.string :output_id
      t.string :elt_id
      t.text :usertxt
      t.string :createusr
      t.string :report_type
      t.string :plan_el_type
      t.integer :year

      t.timestamps
    end
    add_index :narratives, :id, :unique => true
  end

  def down
    remove_index :narratives
    drop_table :narratives
  end
end
