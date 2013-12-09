class ChangeDefaultToZero < ActiveRecord::Migration
  def change
    change_column_default :outputs, :aol_admin_budget, 0
    change_column_default :outputs, :aol_partner_budget, 0
    change_column_default :outputs, :aol_project_budget, 0
    change_column_default :outputs, :aol_staff_budget, 0
    change_column_default :outputs, :ol_admin_budget, 0
    change_column_default :outputs, :ol_partner_budget, 0
    change_column_default :outputs, :ol_project_budget, 0
    change_column_default :outputs, :ol_staff_budget, 0

    change_column_default :problem_objectives, :aol_admin_budget, 0
    change_column_default :problem_objectives, :aol_partner_budget, 0
    change_column_default :problem_objectives, :aol_project_budget, 0
    change_column_default :problem_objectives, :aol_staff_budget, 0
    change_column_default :problem_objectives, :ol_admin_budget, 0
    change_column_default :problem_objectives, :ol_partner_budget, 0
    change_column_default :problem_objectives, :ol_project_budget, 0
    change_column_default :problem_objectives, :ol_staff_budget, 0
  end
end
