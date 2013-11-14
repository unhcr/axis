class ManyToManyStringId < ActiveRecord::Migration
  def change
    change_column :plans_ppgs, :plan_id, :string
    change_column :plans_ppgs, :ppg_id, :string

    change_column :goals_ppgs, :goal_id, :string
    change_column :goals_ppgs, :ppg_id, :string

    change_column :goals_rights_groups, :rights_group_id, :string
    change_column :goals_rights_groups, :goal_id, :string

    change_column :problem_objectives_rights_groups, :rights_group_id, :string
    change_column :problem_objectives_rights_groups, :problem_objective_id, :string

    change_column :outputs_problem_objectives, :output_id, :string
    change_column :outputs_problem_objectives, :problem_objective_id, :string

    change_column :indicators_problem_objectives, :indicator_id, :string
    change_column :indicators_problem_objectives, :problem_objective_id, :string

    change_column :indicators_outputs, :indicator_id, :string
    change_column :indicators_outputs, :output_id, :string
  end
end
