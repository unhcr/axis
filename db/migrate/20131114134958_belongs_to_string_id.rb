class BelongsToStringId < ActiveRecord::Migration
  def change
    change_column :indicator_data, :indicator_id, :string
    change_column :indicator_data, :output_id, :string
    change_column :indicator_data, :problem_objective_id, :string
    change_column :indicator_data, :rights_group_id, :string
    change_column :indicator_data, :goal_id, :string
    change_column :indicator_data, :ppg_id, :string
    change_column :indicator_data, :plan_id, :string

    change_column :budget_lines, :output_id, :string
    change_column :budget_lines, :problem_objective_id, :string
    change_column :budget_lines, :rights_group_id, :string
    change_column :budget_lines, :goal_id, :string
    change_column :budget_lines, :ppg_id, :string
    change_column :budget_lines, :plan_id, :string
  end
end
