class Output < ActiveRecord::Base
  attr_accessible :name, :priority

  has_and_belongs_to_many :indicators

  has_many :indicator_data

  belongs_to :problem_objective
end
