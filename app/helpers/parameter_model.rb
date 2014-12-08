module ParameterModel
  def self.included(base)
    base.extend(ClassMethods)

    if StrategyObjective.parameters.include? base
      through = [base.table_name, 'strategy_objectives'].sort.join('_').to_sym
      class_name = [base.to_s.pluralize, StrategyObjective.to_s.pluralize].sort.join
      base.has_many through, :class_name => class_name
      base.has_many :strategy_objectives,
        :uniq => true,
        :through => through
    end

  end

  module ClassMethods
  end

end

