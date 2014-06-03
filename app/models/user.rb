class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :password_confirmation, :firstname, :lastname, :reset_local_db, :admin

  has_many :export_modules
  has_many :strategies

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :firstname, :lastname, :id, :reset_local_db, :login
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end

  def email
    self.login + '@unhcr.org'
  end

  def self.reset_local_db(users)
    users.each { |u| u.reset_local_db = true; u.save }
  end
end
