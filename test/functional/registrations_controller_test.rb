require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should create new user" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, :user => { :remember_me =>"1",
                   :password => "mypassword",
                   :password_confirmation => "mypassword",
                   :email => "ben@ben.com",
                   :firstname => "asdf",
                   :lastname => "asdf"}

    assert_response :success

    r = JSON.parse(response.body)

    assert r["success"], 'Should be successful in user creation'

    u = User.where(:email => 'ben@ben.com').first
    assert u, 'Should have find the user'
    assert u.email, 'ben@ben.com'
  end

end

