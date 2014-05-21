require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  def setup
    @operation = operations(:one)
    @operation.ppgs << ppgs(:one)
    @operation.goals << goals(:one)
    @operation.outputs << outputs(:one)
    @operation.problem_objectives << problem_objectives(:one)
    @operation.indicators << indicators(:one)
    @operation.save

  end
  test "include options" do
    options = {
      :include => {
        :ids => true,
      }
    }

    json = @operation.as_json

    assert_nil json["goal_ids"]
    assert_nil json["ppg_ids"]
    assert_nil json["output_ids"]
    assert_nil json["indicator_ids"]
    assert_nil json["problem_objective_ids"]

    json = @operation.as_json(options)

    assert_equal json["goal_ids"].length, 1
    assert_equal json["ppg_ids"].length, 1
    assert_equal json["output_ids"].length, 1
    assert_equal json["indicator_ids"].length, 1
    assert_equal json["problem_objective_ids"].length, 1
  end
end
