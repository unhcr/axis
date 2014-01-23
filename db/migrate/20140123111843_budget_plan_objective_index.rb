class BudgetPlanObjectiveIndex < ActiveRecord::Migration
  def up
    add_index :budgets, :problem_objective_id
    add_index :budgets, :output_id
  end

  def down
    remove_index :budgets, :problem_objective_id
    remove_index :budgets, :output_id
  end
end
