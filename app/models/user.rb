class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :firstname, :lastname, :reset_local_db

  has_many :export_modules

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :firstname, :lastname, :id, :reset_local_db
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
