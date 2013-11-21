require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :all
  def setup
    @user = users(:one)

    sign_in @user
  end

  test 'A not signed in user should hit splash page' do

    sign_out @user

    get :index

    assert_response :found
  end

  test 'Splash page' do
    get :splash

    assert_response :success
    assert_template :splash
    assert_template layout: "layouts/application"
  end

  test 'A signed in user should be redirected to navigation page' do

    get :index

    assert_response :success
    assert_not_nil assigns :mapMD5
    assert_template :index
    assert_template layout: "layouts/index"

  end

  test 'map_data should get current plans if no year' do
    get :map_data

    r = JSON.parse(response.body)
    plans = r["plans"]

    assert_response :success
    assert_equal 1, plans.count
    plans.each do |plan|
      assert_equal plan["year"], Time.now.year
    end

  end

  test 'map_data should get passed in year' do

    get :map_data, { :year => 2012 }


    r = JSON.parse(response.body)
    plans = r["plans"]

    assert_response :success
    assert_equal 1, plans.count
    plans.each do |plan|
      assert_equal plan["year"], 2012
    end
  end


end
