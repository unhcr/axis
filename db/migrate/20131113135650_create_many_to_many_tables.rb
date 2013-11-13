class CreateManyToManyTables < ActiveRecord::Migration
  def change
    create_table "plans_ppgs", :id => false do |t|
      t.column "plan_id", :integer, :null => false
      t.column "ppg_id",  :integer, :null => false
    end

    create_table "goals_ppgs", :id => false do |t|
      t.column "goal_id", :integer, :null => false
      t.column "ppg_id",  :integer, :null => false
    end

    create_table "goals_rights_groups", :id => false do |t|
      t.column "goal_id", :integer, :null => false
      t.column "rights_group_id",  :integer, :null => false
    end

    create_table "problem_objectives_rights_groups", :id => false do |t|
      t.column "problem_objective_id", :integer, :null => false
      t.column "rights_group_id",  :integer, :null => false
    end

    create_table "outputs_problem_objectives", :id => false do |t|
      t.column "problem_objective_id", :integer, :null => false
      t.column "output_id",  :integer, :null => false
    end

    create_table "indicators_problem_objectives", :id => false do |t|
      t.column "problem_objective_id", :integer, :null => false
      t.column "indicator_id",  :integer, :null => false
    end

    create_table "indicators_outputs", :id => false do |t|
      t.column "output_id", :integer, :null => false
      t.column "indicator_id",  :integer, :null => false
    end
  end
end
