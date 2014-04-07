module SyncableParameterModel
  def touch_data(assoc)
    self.budgets.update_all(:updated_at => Time.now) if defined? self.budgets
    self.indicator_data.update_all(:updated_at => Time.now) if defined? self.indicator_data
    self.expenditures.update_all(:updated_at => Time.now) if defined? self.expenditures
  end

  def self.included(base)
    base.extend(ClassMethods)

    if StrategyObjective.parameters.include? base
      through = [base.table_name, 'strategy_objectives'].sort.join('_').to_sym
      class_name = [base.to_s.pluralize, StrategyObjective.to_s.pluralize].sort.join
      base.has_many through, :class_name => class_name
      base.has_many :strategy_objectives,
        :uniq => true,
        :through => through,
        :before_add => :touch_data,
        :before_remove => :touch_data
    end

  end

  module ClassMethods
  end

end

