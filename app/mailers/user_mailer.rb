class UserMailer < ActionMailer::Base
  default from: "hqaxis@unhcr.org"

  # This generates the email for when a user shares a strategy to another user
  def share_email(strategy, user, shared_users, host)
    return if shared_users.nil? || shared_users.length == 0

    @strategy = strategy
    @user = user
    @shared_users = shared_users
    @url = "http://#{host}/overview/#{@strategy.id}"
    @host = host

    mail(to: shared_users.map(&:email),
         subject: "#{user.login} has shared strategy '#{strategy.name}' with you")
  end

  # This generates the email for when a user becomes an admin
  def admin_email(user, new_admin, host)
    return if new_admin.nil? || new_admin.length == 0

    @user = user
    @new_admin = new_admin
    @url = "http://#{host}"
    @host = host

    mail(to: new_admin.map(&:email),
         subject: "#{user.login} has made you an admin!")
  end

end
