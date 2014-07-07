require 'test_helper'

class BudgetsControllerTest < ActionController::TestCase
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

  test "should get no budget data" do
    get :synced

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 0, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length
  end

  test "should get one new budget data" do
    datum = Budget.new()
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.save

    get :synced, { :strategy_id => @s.id }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length
  end

  test "should get one new budget data - no output" do
    datum = Budget.new()
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.save

    get :synced, { :strategy_id => @s.id }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length

  end

  test "should get one new budget data - filter_ids" do
    datum = Budget.new()
    datum.operation = operations(:one)
    datum.plan = plans(:one)
    datum.ppg = ppgs(:one)
    datum.goal = goals(:one)
    datum.problem_objective = problem_objectives(:one)
    datum.output = outputs(:one)
    datum.save

    post :synced, { :filter_ids => {
        :operation_ids => [datum.operation_id],
        :ppg_ids => [datum.ppg_id],
        :goal_ids => [datum.goal_id],
        :problem_objective_ids => [datum.problem_objective_id],
        :output_ids => [datum.output_id],
      } }

    assert_response :success

    r = JSON.parse(response.body)

    assert_equal 1, r["new"].length
    assert_equal 0, r["updated"].length
    assert_equal 0, r["deleted"].length
  end
end
