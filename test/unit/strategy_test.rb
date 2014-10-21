require 'test_helper'

class StrategyTest < ActiveSupport::TestCase
  def setup
    @s = strategies(:one)

    @operations = [operations(:one)]
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

    @s.operations << @operations
    @s.plans << @plans
    @s.ppgs << @ppgs
    @s.rights_groups << @rights_groups

    @s.strategy_objectives << @so
  end

  test "update nested" do
    s = Strategy.create()

    s_json = ActiveSupport::HashWithIndifferentAccess.new(
      :operations => [Operation.first.as_json]
    )

    s.update_nested s_json

    s.reload
    assert_equal s.operations.length, 1

    s_json[:strategy_objectives] = [{ :name => 'weird', :goals => [Goal.first.as_json] }]

    s.update_nested s_json

    s.reload
    assert_equal s.operations.length, 1
    assert_equal s.strategy_objectives.length, 1
    assert_equal s.strategy_objectives[0].goals.length, 1

    s_json[:strategy_objectives] = [
      { :name => 'weird', :goals => [Goal.first.as_json] },
      s.strategy_objectives[0].as_json.as_json
    ]

    s.update_nested s_json

    s.reload
    assert_equal s.operations.length, 1
    assert_equal s.strategy_objectives.length, 2

    s_json[:strategy_objectives] = nil
    s.update_nested s_json

    s.reload
    assert_equal s.operations.length, 1
    assert_equal s.strategy_objectives.length, 0
  end

  test "update nested - any_strategy_objective" do
    s = Strategy.create()

    s_json = ActiveSupport::HashWithIndifferentAccess.new(
      :operations => [Operation.first.as_json]
    )
    s_json[:strategy_objectives] = [
      { :name => 'weird', :goals => [goals(:one).as_json, goals(:two).as_json] }
    ]

    s.update_nested s_json
    s.reload
    assert_equal s.goals.length, 2
    assert_equal s.strategy_objectives.length, 1
    assert_equal s.operations.length, 1

    s_json[:strategy_objectives] = [
      { :name => 'weird', :goals => [goals(:two).as_json] }
    ]
    s.update_nested s_json
    s.reload

    assert_equal s.goals.length, 1
    assert_equal s.strategy_objectives.length, 1
    assert_equal s.operations.length, 1
  end

  test "should get optmized indicator data for strategy" do

    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.is_performance = true
    datum.save

    data = @s.data_optimized(IndicatorDatum)
    assert_equal 1, JSON.parse(data.values[0][0]).length
  end

  test "should get indicator data for strategy" do

    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data(IndicatorDatum)
    assert_equal 1, data.length
  end

  test "should not get indicator data for the strategy" do
    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:two)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data(IndicatorDatum)
    assert_equal 0, data.length
  end

  test "should allow to not have an output" do
    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.indicator = indicators(:one)
    datum.save

    data = @s.data(IndicatorDatum)
    assert_equal 1, data.length
  end

  test "strategy objective should add params to strategy" do
    assert_equal 1, @s.goals.length
    assert_equal 1, @s.problem_objectives.length
    assert_equal 1, @s.outputs.length
    assert_equal 1, @s.indicators.length

    goal2 = goals(:two)
    goal2.indicator_data = [indicator_data(:one)]
    goal2.budgets = [budgets(:one)]
    goal2.expenditures = [expenditures(:one)]
    goal2.save

    assert Time.now > goal2.updated_at
    assert Time.now > goal2.indicator_data[0].updated_at
    assert Time.now > goal2.budgets[0].updated_at
    assert Time.now > goal2.expenditures[0].updated_at

    sleep 2

    @so.goals << goal2
    assert_equal 2, @s.reload.goals.length
    goal2.reload

    @so2 = strategy_objectives(:two)
    @so2.goals << goals(:three)

    @s.strategy_objectives << @so2
    assert_equal 3, @s.reload.goals.length

    @so2.goals << goals(:two)
    assert_equal 3, @s.reload.goals.length

    @so2.goals.delete(goals(:three))
    assert_equal 1, @so2.reload.goals.length
    assert_equal 2, @s.reload.goals.length

    @so2.goals.delete goals(:two)
    assert_equal 0, @so2.reload.goals.length
    assert_equal 2, @s.reload.goals.length

    @so2.goals.delete_all
    @so.goals.delete_all
    assert_equal 0, Strategy.find(@s.id).goals.length
  end

  test "params should be removed when strategy objective is removed" do
    @so2 = strategy_objectives(:two)
    @so2.goals << goals(:three)
    @so2.goals << goals(:one)

    @s.strategy_objectives << @so2
    assert_equal 2, @s.reload.goals.length

    @s.strategy_objectives.delete @so
    @s.reload
    assert_equal 2, @s.goals.length
    assert_equal 0, @s.problem_objectives.length
    assert_equal 0, @s.outputs.length
    assert_equal 0, @s.indicators.length

  end

  test "strategy objectives should be destroyed when strategy is destoryed" do
    strategy_objectives = @s.strategy_objectives

    assert_equal strategy_objectives.length, 1

    @s.destroy

    strategy_objectives.each do |so|
      assert !StrategyObjective.exists?(so.id)
    end

  end

  test "include shared_users" do
    @s.shared_users << users(:one)

    json = @s.as_json({ :include => { :shared_users => true } })

    assert_equal json['shared_users'].length, 1

  end

  test "to workbook" do
    @operations[0].ppgs << @ppgs[0]
    pkg = @s.to_workbook

    assert_equal 2, pkg.workbook.worksheets.length
    assert_equal 'Strategy', pkg.workbook.worksheets[0].name
    assert_equal 'Strategy Objectives', pkg.workbook.worksheets[1].name

    sheet = pkg.workbook.worksheets[0]

    assert_equal @s.name, sheet.cells[0].value
    assert_equal @s.name, sheet.cells[4].value
    assert_equal @s.operations[0].name, sheet.cells[5].value
    assert_equal @s.ppgs[0].name, sheet.cells[6].value
    assert_nil sheet.cells[7]
  end

end
