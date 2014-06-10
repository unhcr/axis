class AddUniqueIndexesToElements < ActiveRecord::Migration
  def up
    add_index :operations, :id, unique: true
    add_index :plans, :id, unique: true
    add_index :goals, :id, unique: true
    add_index :outputs, :id, unique: true
    add_index :rights_groups, :id, unique: true
    add_index :problem_objectives, :id, unique: true
    add_index :ppgs, :id, unique: true
  end

  def down
    remove_index :operations, :id, unique: true
    remove_index :plans, :id
    remove_index :goals, :id
    remove_index :outputs, :id
    remove_index :rights_groups, :id
    remove_index :problem_objectives
    remove_index :ppgs, :id
  end
end
