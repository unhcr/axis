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



end
