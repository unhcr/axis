class AddCostsToOutputs < ActiveRecord::Migration
  def change
    add_column :outputs, :admin_cost, :integer, :default => 0
    add_column :outputs, :partner_cost, :integer, :default => 0
    add_column :outputs, :project_cost, :integer, :default => 0
    add_column :outputs, :staff_cost, :integer, :default => 0

    add_column :problem_objectives, :admin_cost, :integer, :default => 0
    add_column :problem_objectives, :partner_cost, :integer, :default => 0
    add_column :problem_objectives, :project_cost, :integer, :default => 0
    add_column :problem_objectives, :staff_cost, :integer, :default => 0
  end
end
