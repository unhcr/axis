class AddColumnToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :is_deleted, :boolean
  end
end
