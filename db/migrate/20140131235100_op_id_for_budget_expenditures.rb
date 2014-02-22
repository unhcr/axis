class OpIdForBudgetExpenditures < ActiveRecord::Migration
  def change
    add_column :budgets, :operation_id, :string
    add_column :expenditures, :operation_id, :string
  end
end
