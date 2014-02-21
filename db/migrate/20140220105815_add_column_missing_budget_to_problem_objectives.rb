class AddColumnMissingBudgetToProblemObjectives < ActiveRecord::Migration
  def change
    add_column :problem_objectives, :missing_budget, :boolean, { :default => false }
  end
end
