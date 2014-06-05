class Office < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel

  attr_accessible :name, :status, :id, :plan_id, :office_id

  has_many :sub_offices, class_name: 'Office',
    foreign_key: 'parent_office_id'
  has_many :positions

  belongs_to :parent_office, class_name: 'Office'
  belongs_to :operation
  belongs_to :plan

end
