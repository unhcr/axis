class IdForHmt < ActiveRecord::Migration
  def up
    add_column :indicators_plans, :id, :primary_key
    add_column :goals_plans, :id, :primary_key
    add_column :plans_ppgs , :id, :primary_key
    add_column :outputs_plans, :id, :primary_key
    add_column :plans_problem_objectives, :id, :primary_key
  end

  def down
    remove_column :indicators_plans, :id
    remove_column :goals_plans, :id
    remove_column :plans_ppgs , :id
    remove_column :outputs_plans, :id
    remove_column :plans_problem_objectives, :id
  end
end
