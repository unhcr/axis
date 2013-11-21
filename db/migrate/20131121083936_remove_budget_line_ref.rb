class RemoveBudgetLineRef < ActiveRecord::Migration
  def change
    drop_table :budget_lines
  end
end
