require 'test_helper'

class StrategiesControllerTest < ActionController::TestCase
  Plan.all.map { |p| p.operation = Operation.first }
  Plan.all.map &:save
  test "create" do
    post :create, {
      :strategy => {
        :name => 'ben',
        :description => 'rudolph',
        :operations => Operation.all.map(&:id),
        :strategy_objectives => [
          {
            :name => 'lisa',
            :description => 'walker',
            :goals => Goal.all.map(&:id),
            :outputs => Output.all.map(&:id),
            :problem_objectives => ProblemObjective.all.map(&:id),
            :indicators => Indicator.all.map(&:id),
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
    # assert_equal Plan.all.count, s.plans.count
    # TODO Make sure we get this plan count working
  end
end
