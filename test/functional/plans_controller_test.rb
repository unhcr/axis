require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:one)
    sign_in @user
  end

  test 'index should get all plans' do
    get :index

    plans = JSON.parse(response.body)

    assert_response :success
    assert_equal 3, plans.count
  end

  test 'index should get all 2012 plans' do
    get :index, { :where => { :year => 2012 } }

    plans = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, plans.count
    assert_equal plans[0]["year"], 2012
  end

  test 'index should get one page of plans' do
    Plan.per_page = 1

    get :index, { :page => 1 }

    plans = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, plans.count
  end

  test 'index should get plans with situation analysis' do

    p = Plan.where(:year => 2012).first
    p.indicators << indicators(:impact)

    datum = indicator_data(:one)
    datum.is_performance = false
    datum.save

    p.indicator_data << datum
    p.indicators[0].indicator_data << datum

    p.indicators[0].save
    p.save

    get :index, { :where => { :year => 2012 }, :options => { :include => { :situation_analysis => true } } }


    plans = JSON.parse(response.body)

    assert_response :success
    assert_equal 1, plans.count

    plan = plans[0]

    assert_equal IndicatorDatum::ALGO_RESULTS[:ok], plan["situation_analysis"]["category"]
  end
end
