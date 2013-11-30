class Ppg < ActiveRecord::Base
  extend Parameter
  attr_accessible :name

  self.primary_key = :id

  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true

  has_many :indicator_data
  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
