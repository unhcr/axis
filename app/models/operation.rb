class Operation < ActiveRecord::Base
  self.primary_key = :id

  extend Parameter
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Searchable

  attr_accessible :id, :name, :years

  serialize :years, Array

  has_many :plans
  has_many :indicator_data

  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :ppgs, :uniq => true

  def to_indexed_json
    Jbuilder.encode do |json|
      json.extract! self, :name, :id
    end
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :years
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
