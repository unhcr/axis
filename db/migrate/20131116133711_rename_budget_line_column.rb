class RenameBudgetLineColumn < ActiveRecord::Migration
  def change
    rename_column :budget_lines, :type, :cost_type
  end
end
