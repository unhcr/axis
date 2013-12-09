class NewBudgetSchema < ActiveRecord::Migration
  def change
    rename_column :outputs, :admin_budget, :ol_admin_budget
    rename_column :outputs, :partner_budget, :ol_partner_budget
    rename_column :outputs, :project_budget, :ol_project_budget
    rename_column :outputs, :staff_budget, :ol_staff_budget

    add_column :outputs, :aol_admin_budget, :integer
    add_column :outputs, :aol_partner_budget, :integer
    add_column :outputs, :aol_project_budget, :integer
    add_column :outputs, :aol_staff_budget, :integer

    remove_column :outputs, :aol_budget
    remove_column :outputs, :ol_budget

    rename_column :problem_objectives, :admin_budget, :ol_admin_budget
    rename_column :problem_objectives, :partner_budget, :ol_partner_budget
    rename_column :problem_objectives, :project_budget, :ol_project_budget
    rename_column :problem_objectives, :staff_budget, :ol_staff_budget

    add_column :problem_objectives, :aol_admin_budget, :integer
    add_column :problem_objectives, :aol_partner_budget, :integer
    add_column :problem_objectives, :aol_project_budget, :integer
    add_column :problem_objectives, :aol_staff_budget, :integer

    remove_column :problem_objectives, :aol_budget
    remove_column :problem_objectives, :ol_budget
  end
end
