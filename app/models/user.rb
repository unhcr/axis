class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :password, :password_confirmation, :firstname, :lastname, :reset_local_db

  has_many :export_modules

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :firstname, :lastname, :id, :reset_local_db, :login
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
