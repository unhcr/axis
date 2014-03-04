class CounterCaches < ActiveRecord::Migration
  # Custom counter cache due to issues with built in counter cache
  # http://stackoverflow.com/a/9189982/835696
  def up
    add_column :plans, :custom_ppgs_count, :integer, { :default => 0, :null => false }
    add_column :plans, :custom_indicators_count, :integer, { :default => 0, :null => false }
    add_column :plans, :custom_outputs_count, :integer, { :default => 0, :null => false }
    add_column :plans, :custom_problem_objectives_count, :integer, { :default => 0, :null => false }
    add_column :plans, :custom_goals_count, :integer, { :default => 0, :null => false }
  end

  def down
    remove_column :plans, :custom_ppgs_count
    remove_column :plans, :custom_indicators_count
    remove_column :plans, :custom_outputs_count
    remove_column :plans, :custom_problem_objectives_count
    remove_column :plans, :custom_goals_count
  end
end
