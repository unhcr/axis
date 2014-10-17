class IndicatorDatum < ActiveRecord::Base
  include SyncableModel

  attr_accessible :baseline, :imp_target, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :id, :operation_id, :missing_budget, :priority, :excluded, :indicator_type

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
               :problem_objective => :strategy_objectives,
               :indicator => :strategy_objectives,
               :output => :strategy_objectives })
  end

  def self.models(ids = {}, limit = nil, where = {})

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


    indicator_data = IndicatorDatum.loaded.where(query_string)

    indicator_data.where("#{query_string} AND is_deleted = false")
      .where(where).limit(limit)

  end

  def self.models_optimized(ids = {}, limit = nil, where = nil, offset = nil, user_id = nil)
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
    query_string = " AND #{query_string}" unless conditions.empty?

    # Need to include Strategy Objective ids
    sql = "select array_to_json(array_agg(row_to_json(t)))
      from (
        select #{self.table_name}.*,
          (
            select array_to_json(array_agg(row_to_json(d)::json->'strategy_objective_id'))
            from (
              #{([Goal, Output, ProblemObjective, Indicator].map { |c| parameter_sql(c, user_id) }).join(' INTERSECT ')}

            ) as d
        ) as strategy_objective_ids
        from #{self.table_name}
        where is_performance = true

        UNION ALL

        select #{self.table_name}.*,
          (
            select array_to_json(array_agg(row_to_json(d)::json->'strategy_objective_id'))
            from (

              #{([Goal, ProblemObjective, Indicator].map { |c| parameter_sql(c, user_id) }).join(' INTERSECT ')}

            ) as d
        ) as strategy_objective_ids
        from #{self.table_name}
        where is_performance = false

      ) t
      where is_deleted = false #{query_string}"

    sql += " LIMIT #{sanitize(limit)}" unless limit.nil?
    sql += " OFFSET #{sanitize(offset)}" unless offset.nil?


    ActiveRecord::Base.connection.execute(sql)

  end

  def self.parameter_sql(parameterClass, user_id)
    user_sql = ''
    if user_id.nil?
      user_sql = "user_id is NULL"
    else
      user_sql = "(user_id is NULL or user_id = #{user_id})"
    end

    "select strategy_objective_id
    from #{parameterClass.table_name}_strategy_objectives
    inner join strategy_objectives on strategy_objectives.id = #{parameterClass.table_name}_strategy_objectives.strategy_objective_id
    inner join strategies on strategy_objectives.strategy_id = strategies.id
    where #{parameterClass.table_name.singularize}_id = #{self.table_name}.#{parameterClass.table_name.singularize}_id and #{user_sql}"
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :baseline, :comp_target, :imp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr, :is_performance, :year, :indicator_id, :output_id, :problem_objective_id, :goal_id, :ppg_id, :plan_id, :id, :operation_id

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
    if self[reported_value].nil? || self.threshold_green.nil? || self.threshold_red.nil?
      return ALGO_RESULTS[:missing]
    end

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
