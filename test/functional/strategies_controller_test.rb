require 'test_helper'

class StrategiesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:one)
    @user.admin = true
    @user.save

    sign_in @user
  end

  test "user must be authenticated" do
    sign_out @user

    post :create, {}
    assert_response :redirect

    put :update, { :id => 1 }
    assert_response :redirect

    delete :destroy, { :id => 1 }
    assert_response :redirect

    get :download, { :id => 1 }
    assert_response :redirect
  end

  test "create" do
    Plan.all.map { |p| p.operation = Operation.first; p.save }
    post :create, {
      :name => 'ben',
      :description => 'rudolph',
      :operations => Operation.all.as_json,
      :ppgs => Ppg.all.as_json,
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

    assert_response :success
    json = JSON.parse(response.body)

    assert json["strategy"]

    s = Strategy.find(json["strategy"]["id"])

    assert_equal Operation.all.count, s.operations.count
    assert_equal Ppg.all.count, s.ppgs.count
    assert_equal Goal.all.count, s.goals.count
    assert_equal Output.all.count, s.outputs.count
    assert_equal ProblemObjective.all.count, s.problem_objectives.count
    assert_equal Indicator.all.count, s.indicators.count
    assert_equal Plan.all.count, s.plans.count
    assert @user.strategies.empty?

  end

  test 'globalize strategy' do
    @user.admin = true
    @user.save

    s = strategies(:one)
    s.user = @user

    post :globalize, { :id => s.id }

    assert_response :success

    s.reload
    assert !s.user_id

  end

  test 'create - global strategies, not admin' do
    @user.admin = false
    @user.save

    post :create, {
      :name => 'ben',
      :description => 'rudolph',
    }

    assert_response :forbidden
  end

  test 'create - personal strategy' do
    @user.admin = false
    @user.save

    post :create, {
      :name => 'ben',
      :description => 'rudolph',
      :is_personal => true
    }

    assert_response :success
  end

  test "update" do
    Plan.all.map { |p| p.operation = Operation.first; p.save }

    # First create strategy
    s = Strategy.create :name => "old", :description => "old"
    s.operations << operations(:one)
    s.strategy_objectives = [strategy_objectives(:one), strategy_objectives(:two)]

    post :update, {
      :id => s.id,
      :name => 'new',
      :description => 'new',
      :operations => Operation.all.as_json,
      :ppgs => Ppg.all.as_json,
      :strategy_objectives => [
        {
          :name => 'lisa',
          :description => 'walker',
          :goals => Goal.all.as_json,
          :outputs => Output.all.as_json,
          :problem_objectives => ProblemObjective.all.as_json,
          :indicators => Indicator.all.as_json
        },
        {
          :name => 'newblisa',
          :description => 'walker',
          :goals => [Goal.first.as_json],
          :outputs => [Output.first.as_json],
          :problem_objectives => [ProblemObjective.first.as_json],
          :indicators => [Indicator.first.as_json]
        }
      ]
    }

    assert_response :success
    json = JSON.parse(response.body)

    assert json["strategy"]

    s = Strategy.find(json["strategy"]["id"])
    assert_equal s.name, 'new'
    assert_equal s.description, 'new'

    assert_equal 2, s.strategy_objectives.count
    assert_equal Operation.all.count, s.operations.count
    assert_equal Ppg.all.count, s.ppgs.count
    assert_equal Goal.all.count, s.goals.count
    assert_equal Output.all.count, s.outputs.count
    assert_equal ProblemObjective.all.count, s.problem_objectives.count
    assert_equal Indicator.all.count, s.indicators.count
    assert_equal Plan.all.count, s.plans.count

  end
end
