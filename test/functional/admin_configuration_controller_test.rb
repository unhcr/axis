require 'test_helper'

class AdminConfigurationControllerTest < ActionController::TestCase

  include Devise::TestHelpers
  fixtures :all
  def setup
    @user = users(:one)

    sign_in @user
  end

  test 'Should be able to access admin controller' do
    @user.admin = true
    @user.save
    AdminConfiguration.create

    get :edit

    assert_response :success
    assert_not_nil assigns :configuration
  end

  test 'Should not be able to access admin controller' do
    get :edit

    assert_response :forbidden
  end

  test 'Should update admin config' do
    @user.admin = true
    @user.save
    AdminConfiguration.create :default_use_local_db => true

    post :update, { :admin_configuration => { :default_use_local_db => false } }

    assert_response :success
    assert_template :show
    assert_not_nil assigns :configuration
    assert !AdminConfiguration.first.default_use_local_db
  end

  test 'Should get show view' do
    @user.admin = true
    @user.save
    AdminConfiguration.create

    post :show

    assert_response :success
    assert_template :show
    assert_not_nil assigns :configuration
  end
end


