class DefaultColumnBudgets < ActiveRecord::Migration
  def change
    change_column_default :budgets, :amount, 0
  end
end
