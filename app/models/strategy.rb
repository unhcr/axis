class Strategy < ActiveRecord::Base

  DASHBOARD_TYPES = {
    :overview => 'overview',
    :operation => 'operation',
  }
  ANY_STRATEGY_OBJECTIVE = 'ANY_STRATEGY_OBJECTIVE'

  attr_accessible :name, :description, :dashboard_type

  has_many :strategy_objectives,
    :after_remove => :remove_strategy_objective_parameters,
    :before_add => :add_strategy_objective_parameters,
    :dependent => :destroy

  has_many :operations_strategies, :class_name     => 'OperationsStrategies'
  has_many :operations, :uniq => true, :through => :operations_strategies

  has_many :plans_strategies, :class_name    => 'PlansStrategies'
  has_many :plans, :uniq => true, :through => :plans_strategies

  has_many :ppgs_strategies, :class_name    => 'PpgsStrategies'
  has_many :ppgs, :uniq => true, :through => :ppgs_strategies

  has_many :goals_strategies, :class_name    => 'GoalsStrategies'
  has_many :goals, :uniq => true, :before_add => :belongs_to_strategy_objective, :through => :goals_strategies

  has_many :rights_groups_strategies, :class_name    => 'RightsGroupsStrategies'
  has_many :rights_groups, :uniq => true, :through => :rights_groups_strategies

  has_many :problem_objectives_strategies, :class_name     => 'ProblemObjectivesStrategies'
  has_many :problem_objectives, :uniq => true, :before_add => :belongs_to_strategy_objective, :through => :problem_objectives_strategies

  has_many :outputs_strategies, :class_name    => 'OutputsStrategies'
  has_many :outputs, :uniq => true, :before_add => :belongs_to_strategy_objective, :through => :outputs_strategies

  has_many :indicators_strategies, :class_name     => 'IndicatorsStrategies'
  has_many :indicators, :uniq => true, :before_add => :belongs_to_strategy_objective, :through => :indicators_strategies

  belongs_to :user

  has_many :users_strategies, :uniq => true, :class_name => 'UserStrategy'
  has_many :shared_users, :class_name => 'User', :through => :users_strategies

  scope :global_strategies, where(:user_id => nil)


  def add_strategy_objective_parameters(strategy_objective)
    self.goals << strategy_objective.goals
    self.problem_objectives << strategy_objective.problem_objectives
    self.outputs << strategy_objective.outputs
    self.indicators << strategy_objective.indicators
  end

  def remove_strategy_objective_parameters(strategy_objective)
    self.normalize
  end

  def normalize
    parameters = StrategyObjective.parameters
    parameters.each do |p|
      name = p.table_name
      collection = []
      self.strategy_objectives.each do |so|
        collection += so.send(name)
      end
      self.send(name + '=', collection)
    end
  end

  def belongs_to_strategy_objective(assoc)
    raise 'Association does not belong to a Strategy Objective' if assoc.strategy_objectives.empty?
  end

  def parameter_ids
    {
      :operation_ids => self.operation_ids,
      :ppg_ids => self.ppg_ids,
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
    }
  end

  def data_optimized(resource = IndicatorDatum, limit = nil, where = {})
    ids = parameter_ids
    ids[:indicator_ids] = self.indicator_ids if resource == IndicatorDatum
    ids.delete :output_ids if resource == Narrative

    resource.models_optimized ids
  end

  def data(resource = IndicatorDatum, limit = nil, where = {})
    ids = parameter_ids
    ids[:indicator_ids] = self.indicator_ids if resource == IndicatorDatum
    ids.delete :output_ids if resource == Narrative

    resource.models(ids, limit, where)
  end

  def to_workbook
    p = Axlsx::Package.new
    workbook = p.workbook

    workbook.add_worksheet(:name => 'Strategy') do |strategy_ws|
      # Headings
      strategy_ws.add_row [self.name], :sz => 24
      strategy_ws.merge_cells('A1:C1')

      strategy_ws.add_row ['Strategy', 'Operation', 'PPG'], :sz => 16

      # Content
      self.operations.each_with_index do |operation, i|
        operation.ppgs.merge(self.ppgs).each_with_index do |ppg, j|
          strategy_ws.add_row [self.name, operation.name, ppg.name]
        end
      end
    end

    # Write second table

    workbook.add_worksheet(:name => 'Strategy Objectives') do |strategy_objective_ws|

      strategy_objective_ws.add_row ['Strategy Objective', 'Objective', 'Impact Indicator', 'Output', 'Performance Indicator'], :sz => 16

      self.strategy_objectives.each_with_index do |so, i|
        so.problem_objectives.each_with_index do |po, j|
          so.outputs.merge(po.outputs).each_with_index do |o, k|
            so.indicators.merge(o.indicators).each_with_index do |ind, l|

              strategy_objective_ws.add_row [so.name, '', '', o.name, ind.name]
            end
          end

          so.indicators.merge(po.indicators).each_with_index do |ind, m|
            strategy_objective_ws.add_row [so.name, po.objective_name, ind.name]
          end
        end
      end

    end
    p
  end

  def to_jbuilder(options = {})
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description, :user_id, :dashboard_type

      if options[:include][:ids]
        json.operation_ids self.operation_ids.inject({}) { |h, id| h[id] = true; h }
        json.indicator_ids self.indicator_ids.inject({}) { |h, id| h[id] = true; h }
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
        json.ppg_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.output_ids self.output_ids.inject({}) { |h, id| h[id] = true; h }
        json.plan_ids self.plan_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
        json.strategy_objective_ids self.strategy_objective_ids.inject({}) { |h, id| h[id] = true; h }
      end

      if options[:include][:strategy_objectives]
        json.strategy_objectives self.strategy_objectives
      end

      if options[:include][:shared_users]
        json.shared_users self.shared_users
      end
      json.operations self.operations if options[:include][:operations]
      json.ppgs self.ppgs if options[:include][:ppgs]
    end
  end

  def update_nested(strategy_json)
    self.operation_ids = strategy_json[:operations].map { |o| o['id'] } if strategy_json[:operations]

    # Load all related plans
    self.plans = Plan.where(:operation_id => self.operation_ids) if strategy_json[:operations]

    # Load all related ppgs
    self.ppg_ids = strategy_json[:ppgs].map { |ppg| ppg['id'] } if strategy_json[:ppgs]

    strategy_objective_ids = (strategy_json[:strategy_objectives] || [])
      .select { |json| json['id'].present? }
      .map { |json| json['id'] }
    deleted_strategy_objective_ids = self.strategy_objective_ids - strategy_objective_ids

    StrategyObjective.destroy(deleted_strategy_objective_ids)

    self.strategy_objective_ids = strategy_objective_ids.select do
      |d| d != ANY_STRATEGY_OBJECTIVE
    end

    if strategy_json[:strategy_objectives]
      strategy_json[:strategy_objectives].each do |json|
        so = nil
        if json['id'].present? and json['id'] != ANY_STRATEGY_OBJECTIVE
          so = self.strategy_objectives.find(json['id'])
        else
          so = self.strategy_objectives.new()
        end

        so.update_attributes(
          :name => json['name'],
          :description => json['description'])

        params = [:goals, :outputs, :problem_objectives, :indicators]
        params.each do |param|
          next unless json[param].present?
          method = (param.to_s.singularize + '_ids=').to_sym
          ids = json[param].map { |p| p['id'] }
          so.send method, ids
        end
        so.save
      end
    end
    self.save
    self
  end

  def to_json(options = {})
    to_jbuilder(options).target!
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
