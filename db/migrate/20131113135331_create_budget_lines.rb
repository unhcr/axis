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

      t.timestamps
    end
  end
end
