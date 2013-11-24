class OlAolBudget < ActiveRecord::Migration
  def change
    add_column :outputs, :aol_budget, :integer, default: 0
    add_column :outputs, :ol_budget, :integer, default: 0

    add_column :problem_objectives, :aol_budget, :integer, default: 0
    add_column :problem_objectives, :ol_budget, :integer, default: 0
  end
end
