class AddIndexesToOperationTables < ActiveRecord::Migration
  def up
    add_index :indicators_operations, :operation_id unless index_exists? :indicators_operations, :operation_id
    add_index :goals_operations, :operation_id
    add_index :operations_ppgs, :operation_id
    add_index :operations_outputs, :operation_id
    add_index :operations_problem_objectives, :operation_id

    add_index :indicators_operations, :indicator_id
    add_index :goals_operations, :goal_id
    add_index :operations_ppgs, :ppg_id
    add_index :operations_outputs, :output_id
    add_index :operations_problem_objectives, :problem_objective_id
  end

  def down
    remove_index :indicators_operations, :operation_id
    remove_index :goals_operations, :operation_id
    remove_index :operations_ppgs, :operation_id
    remove_index :operations_outputs, :operation_id
    remove_index :operations_problem_objectives, :operation_id

    remove_index :indicators_operations, :indicator_id
    remove_index :goals_operations, :goal_id
    remove_index :operations_ppgs, :ppg_id
    remove_index :operations_outputs, :output_id
    remove_index :operations_problem_objectives, :problem_objective_id
  end
end
