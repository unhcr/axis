class Goal < ActiveRecord::Base
  extend Parameter
  attr_accessible :name

  self.primary_key  = :id
  has_many :indicator_data

  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
