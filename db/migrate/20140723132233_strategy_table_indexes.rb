class StrategyTableIndexes < ActiveRecord::Migration
  def up
    add_index :plans_strategies, :strategy_id
    add_index :indicators_strategies, :strategy_id
    add_index :ppgs_strategies, :strategy_id
    add_index :outputs_strategies, :strategy_id
    add_index :operations_strategies, :strategy_id
    add_index :problem_objectives_strategies, :strategy_id
  end

  def down
    remove_index :plans_strategies, :strategy_id
    remove_index :indicators_strategies, :strategy_id
    remove_index :ppgs_strategies, :strategy_id
    remove_index :outputs_strategies, :strategy_id
    remove_index :operations_strategies, :strategy_id
    remove_index :problem_objectives_strategies, :strategy_id
  end
end
