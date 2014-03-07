module SyncableParameterModel
  def touch_data
    self.budgets.map &:touch if defined? self.budgets
    self.indicator_data.map &:touch if defined? self.indicator_data
    self.expenditures.map &:touch if defined? self.expenditures
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.before_save :touch_data
  end

  module ClassMethods
  end

end

