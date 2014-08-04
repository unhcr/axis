class UserMailer < ActionMailer::Base
  default from: "hqaxis@unhcr.org"

  def share_email(strategy, user, shared_users)
    @strategy = strategy
    @user = user
    @shared_users = shared_users
    @url = "http://axis.unhcr.org/overview/#{@strategy.id}"

    mail(to: shared_users.map(&:email),
         subject: "#{user.login} has shared strategy '#{strategy.name}' with you")
  end
end
