require 'test_helper'

class ProblemObjectiveTest < ActiveSupport::TestCase
  fixtures :all
  def setup
    @po = problem_objectives(:one)
    @po.operations << operations(:one)
    @po.outputs << outputs(:one)
    @po.indicators << indicators(:one)
    @po.goals << goals(:one)
    @po.ppgs << ppgs(:one)
    @po.save

  end

  test "include options" do
    options = {
      :include => {
        :ids => true,
      }
    }

    json = @po.as_json

    assert_nil json["output_ids"]
    assert_nil json["goal_ids"]
    assert_nil json["operation_ids"]
    assert_nil json["indicator_ids"]
    assert_nil json["ppg_ids"]

    json = @po.as_json(options)

    assert_equal json["output_ids"].length, 1
    assert_equal json["ppg_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
    assert_equal json["goal_ids"].length, 1
    assert_equal json["indicator_ids"].length, 1
  end
end
