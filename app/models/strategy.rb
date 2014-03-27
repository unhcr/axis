class Strategy < ActiveRecord::Base
  attr_accessible :name, :description

  has_many :strategy_objectives,
    :before_add => :add_strategy_objective_parameters, :dependent => :destroy

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


  def add_strategy_objective_parameters(strategy_objective)
    self.goals << strategy_objective.goals
    self.problem_objectives << strategy_objective.problem_objectives
    self.outputs << strategy_objective.outputs
    self.indicators << strategy_objective.indicators
  end

  def belongs_to_strategy_objective(assoc)
    raise 'Association does not belong to a Strategy Objective' if assoc.strategy_objectives.empty?
  end

  def synced(resource, synced_date = nil, limit = nil, where = {})
    ids = {
      :operation_ids => self.operation_ids,
      :ppg_ids => self.ppg_ids,
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
    }

    ids[:indicator_ids] = self.indicator_ids if resource == IndicatorDatum

    resource.synced_models(ids, synced_date, limit, where)
  end

  def to_sheet
    session = GoogleDrive.login(ENV['DRIVE_USERNAME'], ENV['DRIVE_PASSWORD'])

    template = session.spreadsheet_by_key(ENV['DRIVE_SHEET_KEY'])

    sheet = template.duplicate
    sheet.title = "#{self.name} -- #{Time.now}"

    strategy_ws = sheet.worksheets[0]
    strategy_objective_ws = sheet.worksheets[1]

    cols = {
      :strategy => 1,
      :operation => 2,
      :ppg => 3,
    }

    # Write first table

    # Headings
    strategy_ws[1, cols[:strategy]] = 'Strategy'
    strategy_ws[1, cols[:operation]] = 'Operation'
    strategy_ws[1, cols[:ppg]] = 'PPG'

    # Content
    offset = 0
    self.operations.each_with_index do |operation, i|
      operation_ppgs = self.ppgs.merge(operation.ppgs)
      len = operation_ppgs.count
      operation_ppgs.each_with_index do |ppg, j|
        row = offset + j + 2
        strategy_ws[row, cols[:strategy]] = self.name
        strategy_ws[row, cols[:operation]] = operation.name
        strategy_ws[row, cols[:ppg]] = ppg.name
      end
      offset += len
    end

    cols = {
      :strategy_objective => 1,
      :problem_objective => 2,
      :impact_indicator => 3,
      :output => 4,
      :performance_indicator => 5
    }

    # Write second table

    # Headings
    strategy_objective_ws[1, cols[:strategy_objective]] = 'Strategy Objective'
    strategy_objective_ws[1, cols[:problem_objective]] = 'Objective'
    strategy_objective_ws[1, cols[:impact_indicator]] = 'Impact Indicator'
    strategy_objective_ws[1, cols[:output]] = 'Output'
    strategy_objective_ws[1, cols[:performance_indicator]] = 'Performance Indicator'

    # Content
    offset = 2
    self.strategy_objectives.each_with_index do |so, i|
      so.problem_objectives.each_with_index do |po, j|
        so.outputs.merge(po.outputs).each_with_index do |o, k|

          so_indicators = so.indicators.merge(o.indicators)
          count_ind = so_indicators.count
          so_indicators.each_with_index do |ind, l|

            row = offset + l
            strategy_objective_ws[row, cols[:strategy_objective]] = so.name
            strategy_objective_ws[row, cols[:output]] = o.name
            strategy_objective_ws[row, cols[:performance_indicator]] = ind.name
          end
          offset += count_ind
        end

        so_indicators = so.indicators.merge(po.indicators)
        count_ind = so_indicators.count
        so_indicators.each_with_index do |ind, m|
            row = offset + m
            strategy_objective_ws[row, cols[:strategy_objective]] = so.name
            strategy_objective_ws[row, cols[:problem_objective]] = po.objective_name
            strategy_objective_ws[row, cols[:impact_indicator]] = ind.name
            count_ind = m
        end
        offset += count_ind
      end
    end

    strategy_ws.save
    strategy_objective_ws.save
    sheet

  end

  def to_jbuilder(options = {})
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description

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
    self.strategy_objective_ids = strategy_objective_ids
    if strategy_json[:strategy_objectives]
      strategy_json[:strategy_objectives].each do |json|
        so = json['id'].present? ? self.strategy_objectives.find(json['id']) :
          self.strategy_objectives.new()
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
