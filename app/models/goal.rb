class Goal < ActiveRecord::Base
  attr_accessible :name

  has_many :rights_groups
  has_many :indicator_data

  has_and_belongs_to_many :ppgs
end
