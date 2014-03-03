require 'test_helper'

class StrategiesControllerTest < ActionController::TestCase
  test "create" do
    Plan.all.map { |p| p.operation = Operation.first; p.save }
    post :create, {
      :strategy => {
        :name => 'ben',
        :description => 'rudolph',
        :operations => Operation.all.as_json,
        :strategy_objectives => [
          {
            :name => 'lisa',
            :description => 'walker',
            :goals => Goal.all.as_json,
            :outputs => Output.all.as_json,
            :problem_objectives => ProblemObjective.all.as_json,
            :indicators => Indicator.all.as_json
          }
        ]

      }
    }

    assert_response :success
    json = JSON.parse(response.body)

    assert json["strategy"]

    s = Strategy.find(json["strategy"]["id"])

    assert_equal Operation.all.count, s.operations.count
    assert_equal Goal.all.count, s.goals.count
    assert_equal Output.all.count, s.outputs.count
    assert_equal ProblemObjective.all.count, s.problem_objectives.count
    assert_equal Indicator.all.count, s.indicators.count
    assert_equal Plan.all.count, s.plans.count
  end

  test "update" do
    Plan.all.map { |p| p.operation = Operation.first; p.save }

    # First create strategy
    s = Strategy.create :name => "old", :description => "old"
    s.operations << operations(:one)
    s.strategy_objectives = [strategy_objectives(:one), strategy_objectives(:two)]

    post :update, {
      :id => s.id,
      :strategy => {
        :name => 'new',
        :description => 'new',
        :operations => Operation.all.as_json,
        :strategy_objectives => [
          {
            :name => 'lisa',
            :description => 'walker',
            :goals => Goal.all.as_json,
            :outputs => Output.all.as_json,
            :problem_objectives => ProblemObjective.all.as_json,
            :indicators => Indicator.all.as_json
          }
        ]
      }
    }

    assert_response :success
    json = JSON.parse(response.body)

    assert json["strategy"]

    s = Strategy.find(json["strategy"]["id"])
    assert_equal s.name, 'new'
    assert_equal s.description, 'new'

    assert_equal 1, s.strategy_objectives.count
    assert_equal Operation.all.count, s.operations.count
    assert_equal Goal.all.count, s.goals.count
    assert_equal Output.all.count, s.outputs.count
    assert_equal ProblemObjective.all.count, s.problem_objectives.count
    assert_equal Indicator.all.count, s.indicators.count
    assert_equal Plan.all.count, s.plans.count

  end
end
