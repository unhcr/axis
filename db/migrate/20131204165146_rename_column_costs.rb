class RenameColumnCosts < ActiveRecord::Migration
  def change
    rename_column :outputs, :admin_cost, :admin_budget
    rename_column :outputs, :partner_cost, :partner_budget
    rename_column :outputs, :project_cost, :project_budget
    rename_column :outputs, :staff_cost, :staff_budget

    rename_column :problem_objectives, :admin_cost, :admin_budget
    rename_column :problem_objectives, :partner_cost, :partner_budget
    rename_column :problem_objectives, :project_cost, :project_budget
    rename_column :problem_objectives, :staff_cost, :staff_budget
  end
end
