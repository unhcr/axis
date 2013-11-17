require 'test_helper'

class StrategyTest < ActiveSupport::TestCase
  def setup

    @s = strategies(:one)

    @ops = [operations(:one)]
    @plans = [plans(:one)]
    @ppgs = [ppgs(:one)]
    @rights_groups = [rights_groups(:one)]
    @goals = [goals(:one)]
    @pos = [problem_objectives(:one)]
    @outputs = [outputs(:one)]
    @indicators = [indicators(:one)]

    @s.operations << @ops
    @s.ppgs << @ppgs
    @s.rights_groups << @rights_groups
    @s.goals << @goals
    @s.problem_objectives << @pos
    @s.outputs << @outputs
    @s.indicators << @indicators

  end

  test "should get indicator data for strategy" do

    datum = IndicatorDatum.new()
    datum.operation = operations(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data
    assert_equal 1, data.length
  end

  test "should not get indicator data for the strategy" do
    datum = IndicatorDatum.new()
    datum.operation = operations(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:two)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data
    assert_equal 0, data.length
  end

  test "should allow to not have an output" do
    datum = IndicatorDatum.new()
    datum.operation = operations(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data
    assert_equal 1, data.length
  end
end
