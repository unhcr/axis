class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :password_confirmation, :firstname, :lastname, :reset_local_db, :admin

  has_many :export_modules
  has_many :strategies

  has_many :users_strategies, :uniq => true, :class_name => 'UserStrategy'
  has_many :shared_strategies, :class_name => 'Strategy', :through => :users_strategies

  scope :admin_users, -> { where(admin: true) }

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :firstname, :lastname, :id, :reset_local_db, :login

    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end

  # Returns newly shared users
  def share_strategy(other_users, strategy)

    return nil if not strategy or not other_users or not self.strategies.include? strategy

    # Notify new shared users by email if a strategy has been shared
    new_users = other_users - strategy.shared_users

    strategy.shared_users = other_users

    new_users
  end

  def email
    self.login + '@unhcr.org'
  end

  def self.reset_local_db(users)
    users.each { |u| u.reset_local_db = true; u.save }
  end
end
