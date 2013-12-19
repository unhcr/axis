class CreateStrategyObjectives < ActiveRecord::Migration
  def change
    create_table :strategy_objectives do |t|
      t.string :name
      t.text :description
      t.belongs_to :strategy

      t.timestamps
    end

    create_table "operations_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "operation_id",  :string, :null => false
    end

    create_table "ppgs_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "ppg_id",  :string, :null => false
    end

    create_table "goals_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "goal_id", :string, :null => false
    end

    create_table "rights_groups_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "rights_group_id",  :string, :null => false
    end

    create_table "outputs_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "output_id",  :string, :null => false
    end

    create_table "problem_objectives_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "problem_objective_id", :string, :null => false
    end

    create_table "indicators_strategy_objectives", :id => false do |t|
      t.column "strategy_objective_id", :integer, :null => false
      t.column "indicator_id",  :string, :null => false
    end

  end
end
