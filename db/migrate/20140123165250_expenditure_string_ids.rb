class ExpenditureStringIds < ActiveRecord::Migration
  def change
    change_column :expenditures, :plan_id, :string
    change_column :expenditures, :ppg_id, :string
    change_column :expenditures, :goal_id, :string
    change_column :expenditures, :output_id, :string
    change_column :expenditures, :problem_objective_id, :string
  end
end
