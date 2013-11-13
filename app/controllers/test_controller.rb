class TestController < ActionController::Base
  protect_from_forgery

  def user_setup
    # Destroy test user
    u = User.where(:email => 'r@r.com').first
    User.destroy(u.id) if u

    a = User.where(:email => 'test@test.com').first
    unless a
      a = User.create(
        :email => 'test@test.com',
        :password => 'TeStInG!',
        :password_confirmation => 'TeStInG!')
    end

    #sign out any user
    sign_out(:user)

    render :json => u
  end

  def user_teardown
    u = User.where(:email => 'r@r.com').first
    User.destroy(u.id) if u

    a = User.where(:email => 'test@test.com').first
    User.destroy(a.id) if a
    sign_out(:user)

    render :json => { :success => true }
  end

  def user_signed_in
    render :json => { :user_sign_in => user_sign_in? }
  end
end

