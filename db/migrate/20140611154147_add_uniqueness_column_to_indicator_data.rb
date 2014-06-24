class AddUniquenessColumnToIndicatorData < ActiveRecord::Migration
  def up
    add_index :indicator_data, [:indicator_id, :plan_id, :ppg_id, :goal_id, :problem_objective_id, :operation_id],
      :name => 'by_uniqueness', :length =>
        { :operation_id => 10, :indicator_id => 60, :plan_id => 60, :ppg_id => 10, :goal_id => 2,
          :problem_objective_id => 60 }
  end
  def down
    remove_index :indicator_data, :name => 'by_uniqueness'
  end
end
