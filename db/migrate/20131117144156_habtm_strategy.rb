class HabtmStrategy < ActiveRecord::Migration
  def change
    create_table "operations_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "operation_id",  :string, :null => false
    end

    create_table "ppgs_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "ppg_id",  :string, :null => false
    end

    create_table "goals_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "goal_id", :string, :null => false
    end

    create_table "rights_groups_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "rights_group_id",  :string, :null => false
    end

    create_table "outputs__strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "output_id",  :string, :null => false
    end

    create_table "problem_objectives_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "problem_objective_id", :string, :null => false
    end

    create_table "indicators_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "indicator_id",  :string, :null => false
    end

  end
end
