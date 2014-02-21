class FixMissingBudget < ActiveRecord::Migration
  def change
    remove_column :problem_objectives, :missing_budget
    remove_column :outputs, :priority
    add_column :indicator_data, :missing_budget, :boolean, { :default => false }
  end
end
