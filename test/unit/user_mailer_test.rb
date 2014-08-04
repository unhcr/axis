require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'share' do
    user = users(:one)
    new_users = [users(:two)]
    s = strategies(:one)

    email = UserMailer.share_email(s, user, new_users).deliver

    assert !ActionMailer::Base.deliveries.empty?

    assert_equal ['hqaxis@unhcr.org'], email.from
    assert_equal new_users.map(&:email), email.to
  end
end
