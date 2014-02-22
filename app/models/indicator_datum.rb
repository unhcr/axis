class IndicatorDatum < ActiveRecord::Base
  include SyncableModel

  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :id, :opeartion_id, :missing_budget

  self.primary_key = :id
  belongs_to :indicator
  belongs_to :output
  belongs_to :problem_objective
  belongs_to :rights_group
  belongs_to :goal
  belongs_to :ppg
  belongs_to :plan
  belongs_to :operation


  ALGO_RESULTS = {
    :success => 'success',
    :ok => 'ok',
    :fail => 'fail',
    :missing => 'missing'
  }

  REPORTED_VALUES = {
    :myr => 'myr',
    :yer => 'yer'
  }

  SUCCESS_THRESHOLD = 0.66
  OK_THRESHOLD = 0.33

  def self.loaded
    includes({ :goal => :strategy_objectives,
               :problem_objective => [:strategy_objectives, :outputs],
               :indicator => :strategy_objectives,
               :output => :strategy_objectives})
  end

  def self.synced_models(ids = {}, synced_date = nil, limit = nil, where = {})

    synced_data = {}

    conditions = []

    conditions << "operation_id IN ('#{ids[:operation_ids].join("','")}')" if ids[:operation_ids]
    conditions << "plan_id IN ('#{ids[:plan_ids].join("','")}')" if ids[:plan_ids]
    conditions << "ppg_id IN ('#{ids[:ppg_ids].join("','")}')" if ids[:ppg_ids]
    conditions << "goal_id IN ('#{ids[:goal_ids].join("','")}')" if ids[:goal_ids]
    conditions << "indicator_id IN ('#{ids[:indicator_ids].join("','")}')" if ids[:indicator_ids]

    if ids[:problem_objective_ids] && ids[:output_ids]
      conditions << "(problem_objective_id IN ('#{ids[:problem_objective_ids].join("','")}') OR
                     output_id IN ('#{ids[:output_ids].join("','")}'))"
    elsif ids[:problem_objective_ids]
      conditions << "problem_objective_id IN ('#{ids[:problem_objective_ids].join("','")}')"
    elsif ids[:output_ids]
      conditions << "output_id IN ('#{ids[:output_ids].join("','")}')"
    end
    query_string = conditions.join(' AND ')


    indicator_data = IndicatorDatum.loaded

    if synced_date
      synced_data[:new] = indicator_data.where("#{query_string} AND
        created_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:updated] = indicator_data.where("#{query_string} AND
        created_at < :synced_date AND
        updated_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:deleted] = indicator_data.where("#{query_string} AND
        updated_at >= :synced_date AND
        is_deleted = true", { :synced_date => synced_date })
          .where(where).limit(limit)
    else
      synced_data[:new] = indicator_data.where("#{query_string} AND is_deleted = false")
        .where(where).limit(limit)
      synced_data[:updated] = synced_data[:deleted] = IndicatorDatum.limit(0)
    end

    return synced_data

  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :indicator_id, :output_id, :problem_objective_id, :goal_id, :ppg_id, :plan_id, :id, :operation_id

      json.missing_budget self.missing_budget?
      json.strategy_objective_ids self.strategy_objective_ids

    end

  end

  def strategy_objective_ids
    strategy_objective_ids = self.goal.strategy_objective_ids &
      self.problem_objective.strategy_objective_ids &
      self.indicator.strategy_objective_ids
    strategy_objective_ids &= self.output.strategy_objective_ids if self.output
    strategy_objective_ids
  end

  def missing_budget?
    self.missing_budget
  end

  def situation_analysis(reported_value = REPORTED_VALUES[:myr])
    return ALGO_RESULTS[:missing] unless self[reported_value]

    if self[reported_value] >= self.threshold_green
      return ALGO_RESULTS[:success]
    elsif self[reported_value] >= self.threshold_red
      return ALGO_RESULTS[:ok]
    else
      return ALGO_RESULTS[:fail]
    end

  end

  def self.situation_analysis(indicator_data, reported_value = REPORTED_VALUES[:myr])
    counts = {}
    counts[ALGO_RESULTS[:success]] = 0
    counts[ALGO_RESULTS[:ok]] = 0
    counts[ALGO_RESULTS[:fail]] = 0
    counts[ALGO_RESULTS[:missing]] = 0


    indicator_data.each do |datum|
      counts[datum.situation_analysis()] += 1
    end

    count = (counts[ALGO_RESULTS[:success]] +
             counts[ALGO_RESULTS[:ok]] +
             counts[ALGO_RESULTS[:fail]]).to_f

    result = (counts[ALGO_RESULTS[:success]] / count) + (0.5 * (counts[ALGO_RESULTS[:ok]] / count))
    category = ALGO_RESULTS[:fail]

    if result >= SUCCESS_THRESHOLD
      category = ALGO_RESULTS[:success]
    elsif result >= OK_THRESHOLD
      category = ALGO_RESULTS[:ok]
    end

    return {
      :result => result.nan? ? nil : result,
      :category => category
    }

  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
