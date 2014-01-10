class HabtmGoalsPos < ActiveRecord::Migration
  def change
    create_table "goals_problem_objectives", :id => false do |t|
      t.column "goal_id", :string, :null => false
      t.column "problem_objective_id",  :string, :null => false
    end
  end
end
