class Indicator < ActiveRecord::Base
  self.primary_key  = :id

  extend SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Searchable

  attr_accessible :is_gsp, :is_performance, :name

  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :strategy_objectives, :uniq => true


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
