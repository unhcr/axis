class AddParameterIndicatorDataIndexes < ActiveRecord::Migration
  def up
    unless index_exists? :indicator_data, :goal_id
      add_index :indicator_data, :goal_id
    end
    unless index_exists? :indicator_data, :indicator_id
      add_index :indicator_data, :indicator_id
    end
    unless index_exists? :indicator_data, :problem_objective_id
      add_index :indicator_data, :problem_objective_id
    end
    unless index_exists? :indicator_data, :output_id
      add_index :indicator_data, :output_id
    end

    unless index_exists? :expenditures, :goal_id
      add_index :expenditures, :goal_id
    end
    unless index_exists? :expenditures, :problem_objective_id
      add_index :expenditures, :problem_objective_id
    end
    unless index_exists? :expenditures, :output_id
      add_index :expenditures, :output_id
    end

    unless index_exists? :budgets, :goal_id
      add_index :budgets, :goal_id
    end
    unless index_exists? :budgets, :problem_objective_id
      add_index :budgets, :problem_objective_id
    end
    unless index_exists? :budgets, :output_id
      add_index :budgets, :output_id
    end
  end

  def down
    remove_index :indicator_data, :goal_id
    remove_index :indicator_data, :indicator_id
    remove_index :indicator_data, :problem_objective_id
    remove_index :indicator_data, :output_id

    remove_index :budgets, :goal_id
    remove_index :budgets, :problem_objective_id
    remove_index :budgets, :output_id

    remove_index :expenditures, :goal_id
    remove_index :expenditures, :problem_objective_id
    remove_index :expenditures, :output_id
  end
end
