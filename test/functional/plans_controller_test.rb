require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  test 'plans index should get current plans if no year' do
    get :index

    r = JSON.parse(response.body)
    plans = r["plans"]["new"]

    assert_response :success
    assert_equal 1, plans.count
    plans.each do |plan|
      assert_equal plan["year"], Time.now.year
      assert_equal 0, plan["indicators_count"]
      assert_equal 0, plan["ppgs_count"]
      assert_equal 0, plan["goals_count"]
      assert_equal 0, plan["problem_objectives_count"]
      assert_equal 0, plan["outputs_count"]
    end

  end

  test 'plans index should get passed in year' do

    get :index, { :year => 2012 }


    r = JSON.parse(response.body)
    plans = r["plans"]["new"]

    assert_response :success
    assert_equal 1, plans.count
    plans.each do |plan|
      assert_equal plan["year"], 2012
      assert_equal 0, plan["ppgs_count"]
      assert_equal 0, plan["goals_count"]
      assert_equal 0, plan["problems_objective_count"]
      assert_equal 0, plan["outputs_count"]
    end
  end

end
