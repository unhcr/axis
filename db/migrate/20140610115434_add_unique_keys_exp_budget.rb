class AddUniqueKeysExpBudget < ActiveRecord::Migration
  def up
    add_index :budgets, [:plan_id, :ppg_id, :goal_id, :problem_objective_id,
      :output_id, :scenario, :year, :budget_type],
      :unique => true, :name => 'by_uniqueness', :length =>
        { :budget_type => 3, :plan_id => 60, :ppg_id => 10, :goal_id => 2, :problem_objective_id => 60,
          :output_id => 60, :scenario => 10 }
    add_index :expenditures, [:plan_id, :ppg_id, :goal_id, :problem_objective_id,
      :output_id, :scenario, :year, :budget_type],
      :unique => true, :name => 'by_uniqueness', :length =>
        { :budget_type => 3, :plan_id => 60, :ppg_id => 10, :goal_id => 2, :problem_objective_id => 60,
          :output_id => 60, :scenario => 10 }
  end

  def down
    remove_index :budgets, :name => 'by_uniqueness'
    remove_index :expenditures, :name => 'by_uniqueness'
  end
end
