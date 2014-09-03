require 'test_helper'

class OutputTest < ActiveSupport::TestCase
  fixtures :all
  def setup
    @o = outputs(:one)
    @o.operations << operations(:one)
    @o.problem_objectives << problem_objectives(:one)
    @o.indicators << indicators(:one)
    @o.ppgs << ppgs(:one)
    @o.goals << goals(:one)
    @o.save

  end

  test "include options" do
    options = {
      :include => {
        :ids => true
      }
    }

    json = @o.as_json

    assert_nil json["problem_objective_ids"]
    assert_nil json["operation_ids"]
    assert_nil json["indicator_ids"]
    assert_nil json["goal_ids"]
    assert_nil json["ppg_ids"]

    json = @o.as_json(options)

    assert_equal json["problem_objective_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
    assert_equal json["indicator_ids"].length, 1
    assert_equal json["goal_ids"].length, 1
    assert_equal json["ppg_ids"].length, 1
  end
end
