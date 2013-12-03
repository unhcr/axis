require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  include AlgorithmHelper

  test 'plans index should get current plans if no year' do
    get :index

    r = JSON.parse(response.body)
    plans = r["new"]

    assert_response :success
    assert_equal 1, plans.count
    plan = plans[0]
    assert_equal plan["year"], Time.now.year

  end

  test 'plans index should get passed in year' do

    get :index, { :year => 2012 }


    r = JSON.parse(response.body)
    plans = r["new"]

    assert_response :success
    assert_equal 1, plans.count
    assert_equal plans[0]["year"], 2012
  end

  test 'plans index should get counts' do
    p = Plan.where(:year => 2012).first
    p.ppgs << ppgs(:one)
    p.save

    get :index, { :year => 2012, :options => { :include => { :counts => true } } }


    r = JSON.parse(response.body)
    plans = r["new"]

    assert_response :success
    assert_equal 1, plans.count

    plan = plans[0]

    assert_equal plan["year"], 2012
    assert_equal 1, plan["ppgs_count"]
    assert_equal 0, plan["goals_count"]
    assert_equal 0, plan["problem_objectives_count"]
    assert_equal 0, plan["outputs_count"]
  end

  test 'plans index should get situation analysis' do

    p = Plan.where(:year => 2012).first
    p.indicators << indicators(:impact)

    datum = indicator_data(:one)

    p.indicator_data << datum
    p.indicators[0].indicator_data << datum

    p.indicators[0].save
    p.save

    get :index, { :year => 2012, :options => { :include => { :situation_analysis => true } } }


    r = JSON.parse(response.body)
    plans = r["new"]

    assert_response :success
    assert_equal 1, plans.count

    plan = plans[0]

    assert_equal AlgorithmHelper::ALGO_COLORS[:ok], plan["situation_analysis"]

  end
end
