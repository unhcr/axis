class CreateExpenditures < ActiveRecord::Migration
  def change
    create_table :expenditures do |t|
      t.string :budget_type
      t.string :scenario
      t.integer :amount, :default => 0
      t.belongs_to :plan
      t.belongs_to :ppg
      t.belongs_to :goal
      t.belongs_to :output
      t.belongs_to :problem_objective
      t.integer :year
      t.boolean :is_deleted, :default => false
      t.datetime :found_at
      t.timestamps
    end

    add_index :expenditures, [:created_at, :updated_at]
    add_index :expenditures, :created_at
    add_index :expenditures, :updated_at
    add_index :expenditures, :is_deleted
  end
end
