class Indicator < ActiveRecord::Base
  extend Parameter
  attr_accessible :is_gsp, :is_performance, :name

  self.primary_key  = :id
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true

  has_many :indicator_data

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :is_gsp, :is_performance, :name, :id
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
