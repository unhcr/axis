class IdsToStringBudgets < ActiveRecord::Migration
  def change
    change_column :budgets, :plan_id, :string
    change_column :budgets, :ppg_id, :string
    change_column :budgets, :goal_id, :string
    change_column :budgets, :output_id, :string
    change_column :budgets, :problem_objective_id, :string
  end
end
