class IndicatorDatum < ActiveRecord::Base
  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :id

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


  def self.synced(ids = {}, synced_date = nil, limit = nil, where = {})

    synced_data = {}

    query_string = "plan_id IN ('#{ids[:plan_ids].join("','")}') AND
      ppg_id IN ('#{(ids[:ppg_ids] || []).join("','")}') AND
      goal_id IN ('#{(ids[:goal_ids] || []).join("','")}') AND
      (problem_objective_id IN ('#{(ids[:problem_objective_ids] || []).join("','")}') OR output_id IN ('#{(ids[:output_ids] || []).join("','")}')) AND
      indicator_id IN ('#{(ids[:indicator_ids] || []).join("','")}')"

    if synced_date
      synced_data[:new] = IndicatorDatum.where("#{query_string} AND
        created_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:updated] = IndicatorDatum.where("#{query_string} AND
        created_at < :synced_date AND
        updated_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:deleted] = IndicatorDatum.where("#{query_string} AND
        updated_at >= :synced_date AND
        is_deleted = true", { :synced_date => synced_date })
          .where(where).limit(limit)
    else
      synced_data[:new] = IndicatorDatum.where("#{query_string} AND is_deleted = false")
        .where(where).limit(limit)
      synced_data[:updated] = synced_data[:deleted] = IndicatorDatum.limit(0)
    end

    return synced_data

  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :indicator_id, :output_id, :problem_objective_id, :goal_id, :ppg_id, :plan_id, :id

      json.missing_budget self.missing_budget?
      strategy_objective_ids = self.goal.strategy_objective_ids &
        self.problem_objective.strategy_objective_ids &
        self.indicator.strategy_objective_ids
      strategy_objective_ids &= self.output.strategy_objective_ids if self.output
      json.strategy_objective_ids strategy_objective_ids

    end

  end

  def missing_budget?
    budgets = Budget.where({
      :plan_id => self.plan_id,
      :ppg_id => self.ppg_id,
      :goal_id => self.goal_id,
      :output_id => self.output_id,
      :problem_objective_id => self.problem_objective_id,
    }).where('amount > 0')

    budgets.empty?
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
