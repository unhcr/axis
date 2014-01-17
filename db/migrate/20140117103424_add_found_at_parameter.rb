class AddFoundAtParameter < ActiveRecord::Migration
  def change
    add_column :plans, :found_at, :datetime
    add_column :operations, :found_at, :datetime
    add_column :ppgs, :found_at, :datetime
    add_column :goals, :found_at, :datetime
    add_column :rights_groups, :found_at, :datetime
    add_column :problem_objectives, :found_at, :datetime
    add_column :outputs, :found_at, :datetime
    add_column :indicators, :found_at, :datetime
    add_column :budgets, :found_at, :datetime
    add_column :indicator_data, :found_at, :datetime
  end
end
