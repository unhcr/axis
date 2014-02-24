class Plan < ActiveRecord::Base
  include SyncableModel

  attr_accessible :name, :operation_name, :year, :operation_id

  self.primary_key = :id

  has_many :plans_ppgs, :class_name => 'PlansPpgs'
  has_many :ppgs, :uniq => true, :through => :plans_ppgs

  has_many :indicators_plans, :class_name => 'IndicatorsPlans'
  has_many :indicators, :uniq => true, :through => :indicators_plans

  has_many :outputs_plans, :class_name => 'OutputsPlans'
  has_many :outputs, :uniq => true, :through => :outputs_plans

  has_many :plans_problem_objectives, :class_name => 'PlansProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :plans_problem_objectives

  has_many :plans_rights_groups, :class_name => 'PlansRightsGroups'
  has_many :rights_groups, :uniq => true, :through => :plans_rights_groups

  has_many :goals_plans, :class_name => 'GoalsPlans'
  has_many :goals, :uniq => true, :through => :goals_plans

  has_many :plans_strategies, :class_name => 'PlansStrategies'
  has_many :strategies, :uniq => true, :through => :plans_strategies


  has_many :indicator_data
  has_many :budgets

  belongs_to :operation
  belongs_to :country

  default_scope { includes([:country]) }

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :operation_name, :year, :id, :operation_id

      if options[:include]

        if options[:include][:counts]
          json.indicators_count self.custom_indicators_count
          json.goals_count self.custom_goals_count
          json.ppgs_count self.custom_ppgs_count
          json.outputs_count self.custom_outputs_count
          json.problem_objectives_count self.custom_problem_objectives_count
        end

        json.ppg_ids self.ppg_ids if options[:include][:ppg_ids].present?
        json.goal_ids self.goal_ids if options[:include][:goal_ids].present?
        json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
        json.output_ids self.output_ids if options[:include][:output_ids].present?
        json.indicator_ids self.indicator_ids if options[:include][:indicator_ids].present?
        if options[:include][:problem_objective_ids].present?
          json.problem_objective_ids self.problem_objective_ids
        end
        if options[:include][:situation_analysis]
          json.situation_analysis self.situation_analysis
        end

      end

      json.country self.country
    end
  end

  def impact_indicators
    @impact_indicators ||= self.indicators.where(:is_performance => false)
    @impact_indicators
  end

  def situation_analysis(reported_value = IndicatorDatum::REPORTED_VALUES[:myr])
    indicator_data = self.indicator_data.where(:is_performance => false)
    indicator_data.situation_analysis(indicator_data, reported_value)
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
