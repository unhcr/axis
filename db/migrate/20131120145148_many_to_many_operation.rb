class ManyToManyOperation < ActiveRecord::Migration
  def change
    create_table "operations_ppgs", :id => false do |t|
      t.column "operation_id", :string, :null => false
      t.column "ppg_id",  :string, :null => false
    end

    create_table "goals_operations", :id => false do |t|
      t.column "goal_id", :string, :null => false
      t.column "operation_id",  :string, :null => false
    end

    create_table "operations_rights_groups", :id => false do |t|
      t.column "operation_id", :string, :null => false
      t.column "rights_group_id",  :string, :null => false
    end

    create_table "problem_objectives_operations", :id => false do |t|
      t.column "problem_objective_id", :string, :null => false
      t.column "operation_id",  :string, :null => false
    end

    create_table "operations_outputs", :id => false do |t|
      t.column "operation_id", :string, :null => false
      t.column "output_id",  :string, :null => false
    end

    create_table "indicators_operations", :id => false do |t|
      t.column "operation_id", :string, :null => false
      t.column "indicator_id",  :string, :null => false
    end

  end
end
