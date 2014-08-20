require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "should update user" do
    user = users(:one)
    user.admin = true
    user.save
    sign_in user

    assert !user.reset_local_db
    user.reset_local_db = true

    put :update, { :id => user.id, :user => user.as_json }

    assert_response :success

    u = User.find(user.id)
    assert u.reset_local_db
  end

  test "should not update not signed in user" do
    user = users(:one)

    assert !user.reset_local_db
    user.reset_local_db = true

    put :update, { :id => user.id, :user => user.as_json }

    assert_response :success

    r = JSON.parse(response.body)
    assert !r["success"]
  end

  test "should not update user with different id" do
    user = users(:one)

    assert !user.reset_local_db
    user.reset_local_db = true

    put :update, { :id => user.id, :user => user.as_json }

    assert_response :success

    r = JSON.parse(response.body)
    assert !r["success"]
  end

  test "share strategies" do
    user2 = users(:two)
    user = users(:one)
    s = strategies(:one)
    s.user = user
    user.save
    s.save
    sign_in user

    post :share, { :id => user.id, :strategy_id => s.id, :users => [user2.as_json] }

    assert_response :success

    r = JSON.parse(response.body)
    assert r['success']

    user2.reload
    assert_equal user2.shared_strategies.length, 1
  end

  test "share strategies no users" do
    user = users(:one)
    s = strategies(:one)
    s.user = user
    user.save
    s.save
    sign_in user

    post :share, { :id => user.id, :strategy_id => s.id, :users => nil }

    assert_response :success
    r = JSON.parse(response.body)
    assert r['success']
  end

  test 'update admin' do
    user = users(:one)
    user.admin = true
    user.save

    u2 = users(:two)

    sign_in user

    post :admin, { :users => [user.as_json, u2.as_json] }

    assert_response :success
    r = JSON.parse(response.body)
    assert r['success']

    assert u2.reload.admin
    assert user.reload.admin

  end

  test 'search' do
    user2 = users(:two)
    user = users(:one)

    user.login = 'abc'
    user2.login = 'ade'

    user.save
    user2.save

    get :search, { :query => 'a' }

    assert_response :success

    r = JSON.parse(response.body)
    assert_equal r.length, 2

    get :search, { :query => 'ab' }

    r = JSON.parse(response.body)
    assert_equal r.length, 1

    get :search, { :query => 'abf' }

    r = JSON.parse(response.body)
    assert_equal r.length, 0
  end




end
