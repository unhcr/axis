require 'test_helper'

class StrategyObjectiveTest < ActiveSupport::TestCase
  def setup
    @s = strategies(:one)
    @so = strategy_objectives(:one)

    @so.strategy = @s
    @so.goals << goals(:one)
    @so.outputs << outputs(:one)
    @so.problem_objectives << problem_objectives(:one)
    @so.indicators << indicators(:one)
    @so.save

  end
  test "include options" do
    options = {
      :include => {
        :ids => true,
      }
    }

    json = @so.as_json

    assert_nil json["goal_ids"]
    assert_nil json["output_ids"]
    assert_nil json["indicator_ids"]
    assert_nil json["problem_objective_ids"]

    json = @so.as_json(options)

    assert_equal json["goal_ids"].length, 1
    assert_equal json["output_ids"].length, 1
    assert_equal json["indicator_ids"].length, 1
    assert_equal json["problem_objective_ids"].length, 1
  end
end
