class ManyToManyPlans < ActiveRecord::Migration
  def change
    create_table "goals_plans", :id => false do |t|
      t.column "goal_id", :string, :null => false
      t.column "plan_id",  :string, :null => false
    end

    create_table "plans_rights_groups", :id => false do |t|
      t.column "plan_id", :string, :null => false
      t.column "rights_group_id",  :string, :null => false
    end

    create_table "plans_problem_objectives", :id => false do |t|
      t.column "problem_objective_id", :string, :null => false
      t.column "plan_id",  :string, :null => false
    end

    create_table "plans_outputs", :id => false do |t|
      t.column "plan_id", :string, :null => false
      t.column "output_id",  :string, :null => false
    end

    create_table "indicators_plans", :id => false do |t|
      t.column "plan_id", :string, :null => false
      t.column "indicator_id",  :string, :null => false
    end

  end
end
