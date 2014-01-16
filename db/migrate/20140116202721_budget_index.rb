class BudgetIndex < ActiveRecord::Migration
  def up
    add_index :budgets, [:plan_id, :ppg_id, :goal_id]
  end

  def down
    remove_index :budgets, [:plan_id, :ppg_id, :goal_id]
  end
end
