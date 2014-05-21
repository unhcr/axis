class Office < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel

  attr_accessible :name

  has_many :sub_offices, class_name: 'Office',
    foreign_key: 'head_office_id'
  has_many :positions

  belongs_to :head_office, class_name: 'Office'
  belongs_to :operation
  belongs_to :plan

end
