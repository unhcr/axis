class RemoveColumnsBudgetFromOpo < ActiveRecord::Migration
  def change
    remove_column :outputs, :ol_admin_budget
    remove_column :outputs, :ol_project_budget
    remove_column :outputs, :ol_partner_budget
    remove_column :outputs, :ol_staff_budget
    remove_column :outputs, :aol_admin_budget
    remove_column :outputs, :aol_project_budget
    remove_column :outputs, :aol_partner_budget
    remove_column :outputs, :aol_staff_budget

    remove_column :problem_objectives, :ol_admin_budget
    remove_column :problem_objectives, :ol_project_budget
    remove_column :problem_objectives, :ol_partner_budget
    remove_column :problem_objectives, :ol_staff_budget
    remove_column :problem_objectives, :aol_admin_budget
    remove_column :problem_objectives, :aol_project_budget
    remove_column :problem_objectives, :aol_partner_budget
    remove_column :problem_objectives, :aol_staff_budget
  end
end
