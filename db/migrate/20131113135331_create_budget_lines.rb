class CreateBudgetLines < ActiveRecord::Migration
  def change
    create_table :budget_lines do |t|
      t.string :scenerio
      t.string :type
      t.string :cost_center
      t.string :implementer_code
      t.string :implementer_name
      t.string :account_code
      t.string :account_name
      t.integer :quantity
      t.integer :unit
      t.string :currency
      t.integer :unit_cost
      t.integer :local_cost
      t.integer :amount
      t.text :comment

      t.belongs_to :output
      t.belongs_to :problem_objective
      t.belongs_to :rights_group
      t.belongs_to :goal
      t.belongs_to :ppg
      t.belongs_to :plan

      t.timestamps
    end
  end
end
