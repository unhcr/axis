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

    @so = strategy_objectives(:one)

    @so.goals << @goals
    @so.problem_objectives << @pos
    @so.outputs << @outputs
    @so.indicators << @indicators

    @s.plans << @plans
    @s.ppgs << @ppgs
    @s.rights_groups << @rights_groups

    @s.strategy_objectives << @so
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

    data = @s.synced(IndicatorDatum)
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

    data = @s.synced(IndicatorDatum)
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

    data = @s.synced(IndicatorDatum)
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

    data = @s.synced(IndicatorDatum, Time.now - 3.days)
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

    data = @s.synced(IndicatorDatum, Time.now - 3.days)
    assert_equal 0, data[:updated].length
    assert_equal 0, data[:new].length
    assert_equal 1, data[:deleted].length
  end

  test "strategy objective should add params to strategy" do
    assert_equal 1, @s.goals.length
    assert_equal 1, @s.problem_objectives.length
    assert_equal 1, @s.outputs.length
    assert_equal 1, @s.indicators.length

    @so.goals << goals(:two)
    assert_equal 2, Strategy.find(@s.id).goals.length

    @so2 = strategy_objectives(:two)
    @so2.goals << goals(:three)

    @s.strategy_objectives << @so2
    assert_equal 3, Strategy.find(@s.id).goals.length

    @so2.goals << goals(:two)
    assert_equal 3, Strategy.find(@s.id).goals.length

    @so2.goals.delete(goals(:three))
    assert_equal 1, StrategyObjective.find(@so2.id).goals.length
    assert_equal 2, Strategy.find(@s.id).goals.length

    @so2.goals.destroy_all
    @so.goals.destroy_all
    assert_equal 0, Strategy.find(@s.id).goals.length



  end
end
