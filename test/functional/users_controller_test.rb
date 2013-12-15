require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  test "should update user" do
    user = users(:one)
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

end
