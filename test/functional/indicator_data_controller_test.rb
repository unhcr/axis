require 'test_helper'

class IndicatorDataControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:one)
    sign_in @user

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

  test "index indicator data" do
    get :index

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 0, r.length
  end

  test "index indicator data - strategy id" do
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

    get :index, { :strategy_id => @s.id }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r.length
  end

  test "index indicator data - strategy id - optimized" do
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

    get :index, { :strategy_id => @s.id, :optimize => true }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r.length
  end

  test "index indicator data - optimized impact strategy objective" do
    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.is_performance = false
    datum.indicator = indicators(:one)

    outputs(:one).strategy_objectives << strategy_objectives(:one)
    problem_objectives(:one).strategy_objectives << strategy_objectives(:one)
    goals(:one).strategy_objectives << strategy_objectives(:one)
    indicators(:one).strategy_objectives << strategy_objectives(:one)

    datum.save

    get :index, { :strategy_id => @s.id, :optimize => true }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r.length
    assert_equal r[0]['strategy_objective_ids'].length, 1
  end

  test "index indicator data - strategy id - optimized - deleted" do
    datum = IndicatorDatum.new()
    datum.id = 'abc'
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.rights_group = rights_groups(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.is_deleted = true
    datum.indicator = indicators(:one)
    datum.save

    get :index, { :strategy_id => @s.id, :optimize => true }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 0, r.length
  end
end
