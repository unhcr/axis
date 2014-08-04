require 'test_helper'

class IndicatorDatumTest < ActiveSupport::TestCase
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

  test "should report missing if no threshold in situation analysis" do

    datum = IndicatorDatum.new()
    datum.threshold_green = nil
    datum.threshold_red = nil
    datum.myr = nil
    datum.save

    res = datum.situation_analysis

    assert_equal res, IndicatorDatum::ALGO_RESULTS[:missing]

    datum.threshold_green = 2
    datum.threshold_red = nil
    datum.myr = 10
    datum.save

    res = datum.situation_analysis

    assert_equal res, IndicatorDatum::ALGO_RESULTS[:missing]

    datum.threshold_green = nil
    datum.threshold_red = 2
    datum.myr = 10
    datum.save

    res = datum.situation_analysis

    assert_equal res, IndicatorDatum::ALGO_RESULTS[:missing]

    datum.threshold_green = 10
    datum.threshold_red = 2
    datum.myr = nil
    datum.save

    res = datum.situation_analysis

    assert_equal res, IndicatorDatum::ALGO_RESULTS[:missing]

    datum.threshold_green = 10
    datum.threshold_red = 2
    datum.myr = 4
    datum.save

    res = datum.situation_analysis

    assert res != IndicatorDatum::ALGO_RESULTS[:missing]

  end

  test "should correctly calculate strategy objectives ids" do

    datum = IndicatorDatum.new()
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    assert_equal 1, datum.as_json['strategy_objective_ids'].length
    assert_equal @so.id, datum.as_json['strategy_objective_ids'][0]

    so2 = StrategyObjective.create()

    datum.goal.strategy_objectives << so2
    assert_equal 1, datum.as_json['strategy_objective_ids'].length
    assert_equal @so.id, datum.as_json['strategy_objective_ids'][0]

    datum.problem_objective.strategy_objectives << so2
    datum.output.strategy_objectives << so2
    datum.indicator.strategy_objectives << so2

    assert_equal 2, datum.as_json['strategy_objective_ids'].length
    assert_equal [@so.id, so2.id].sort, datum.as_json['strategy_objective_ids'].sort

  end

end
