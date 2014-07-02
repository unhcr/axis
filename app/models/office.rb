class Office < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel

  attr_accessible :name, :status, :id, :plan_id, :operation_id, :parent_office_id, :year

  has_many :sub_offices, class_name: 'Office',
    foreign_key: 'parent_office_id'
  has_many :positions

  belongs_to :parent_office, class_name: 'Office'
  belongs_to :operation
  belongs_to :plan

  def self.head_offices
    where('parent_office_id is NULL')
  end

  def loaded
    includes([:positions, :sub_offices])
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :status, :plan_id, :operation_id, :parent_office_id, :year

      json.sub_offices self.sub_offices

      json.positions self.positions
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
