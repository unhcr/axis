class UserMailer < ActionMailer::Base
  default from: "hqaxis@unhcr.org"

  def share_email(strategy, user, shared_users, host)
    return if shared_users.nil? || shared_users.length == 0

    @strategy = strategy
    @user = user
    @shared_users = shared_users
    @url = "http://#{host}/overview/#{@strategy.id}"

    mail(to: shared_users.map(&:email),
         subject: "#{user.login} has shared strategy '#{strategy.name}' with you")
  end

  def admin_email(user, new_admin, host)
    return if new_admin.nil? || new_admin.length == 0

    @user = user
    @new_admin = new_admin
    @url = "http://#{host}"

    mail(to: new_admin.map(&:email),
         subject: "#{user.login} has made you an admin!")
  end

end
