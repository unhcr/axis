class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :budget_type
      t.string :scenario
      t.integer :amount
      t.belongs_to :plan
      t.belongs_to :ppg
      t.belongs_to :goal
      t.belongs_to :output
      t.belongs_to :problem_objective

      t.timestamps
    end
  end
end
