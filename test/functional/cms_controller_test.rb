require 'test_helper'

class CmsControllerTest < ActionController::TestCase

  include Devise::TestHelpers
  fixtures :all
  def setup
    @user = users(:one)

    sign_in @user
  end

  test 'CMS Strategy - global' do
    @user.admin = true
    @user.save

    get :strategies

    assert_response :success
    assert_not_nil assigns :strategies
    assert_equal false, assigns(:is_personal)
  end

  test 'CMS Strategy - global - non admin' do
    get :strategies

    assert_response :forbidden
  end

  test 'CMS Strategy - personal' do
    get :strategies, { :is_personal => true }

    assert_response :success
    assert_equal true, assigns(:is_personal)
  end

  test 'CMS Strategy - not signed in' do
    sign_out @user

    get :strategies

    assert_response :found
  end

end

