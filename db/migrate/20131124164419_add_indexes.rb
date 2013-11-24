class AddIndexes < ActiveRecord::Migration
  def change
    unless index_exists?(:outputs_plans,[:plan_id, :output_id])
      add_index(:outputs_plans, [:plan_id, :output_id], :unique => true)
    end
    unless index_exists?(:goals_plans, [:plan_id, :goal_id])
      add_index(:goals_plans, [:plan_id, :goal_id], :unique => true)
    end
    unless index_exists?(:plans_ppgs, [:plan_id, :ppg_id])
      add_index(:plans_ppgs, [:plan_id, :ppg_id], :unique => true)
    end

    unless index_exists?(:plans_problem_objectives, [:plan_id, :problem_objective_id])
      add_index(:plans_problem_objectives, [:plan_id, :problem_objective_id],
              :unique => true, :name => :plans_objectives_index)
    end
  end
end
