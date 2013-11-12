class Plan < ActiveRecord::Base
  attr_accessible :name, :operation, :year

  has_and_belongs_to_many :ppgs

  has_many :indicator_data
end
