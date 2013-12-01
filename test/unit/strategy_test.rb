require 'test_helper'

class StrategyTest < ActiveSupport::TestCase
  def setup

    @s = strategies(:one)

    @plans = [plans(:one)]
    @ppgs = [ppgs(:one)]
    @rights_groups = [rights_groups(:one)]
    @goals = [goals(:one)]
    @pos = [problem_objectives(:one)]
    @outputs = [outputs(:one)]
    @indicators = [indicators(:one)]

    @s.plans << @plans
    @s.ppgs << @ppgs
    @s.rights_groups << @rights_groups
    @s.goals << @goals
    @s.problem_objectives << @pos
    @s.outputs << @outputs
    @s.indicators << @indicators

  end

  test "should get indicator data for strategy" do

    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.synced_data
    assert_equal 1, data[:new].length
    assert_equal 0, data[:updated].length
    assert_equal 0, data[:deleted].length
  end

  test "should not get indicator data for the strategy" do
    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:two)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.synced_data
    assert_equal 0, data[:new].length
    assert_equal 0, data[:updated].length
    assert_equal 0, data[:deleted].length
  end

  test "should allow to not have an output" do
    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.synced_data
    assert_equal 1, data[:new].length
    assert_equal 0, data[:updated].length
    assert_equal 0, data[:deleted].length
  end

  test "should get updated data for strategy" do

    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.created_at = Time.now - 1.week
    datum.save

    data = @s.synced_data(Time.now - 3.days)
    assert_equal 1, data[:updated].length
    assert_equal 0, data[:new].length
    assert_equal 0, data[:deleted].length
  end

  test "should get deleted data for strategy" do

    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.created_at = Time.now - 1.week
    datum.is_deleted = true
    datum.save

    data = @s.synced_data(Time.now - 3.days)
    assert_equal 0, data[:updated].length
    assert_equal 0, data[:new].length
    assert_equal 1, data[:deleted].length

  end
end
