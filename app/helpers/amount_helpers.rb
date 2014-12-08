# AmountHelpers is a module for aggregateable parameters in focus such as Budgets and Expenditures. It generates sql to
# select the data based on parameter ids. Axis uses the snowflake model for all of its data tied to focus.

module AmountHelpers
  def models(ids = {}, limit = nil, where = {})

    conditions = []

    conditions << "operation_id IN ('#{ids[:operation_ids].join("','")}')" if ids[:operation_ids]
    conditions << "plan_id IN ('#{ids[:plan_ids].join("','")}')" if ids[:plan_ids]
    conditions << "ppg_id IN ('#{ids[:ppg_ids].join("','")}')" if ids[:ppg_ids]
    conditions << "goal_id IN ('#{ids[:goal_ids].join("','")}')" if ids[:goal_ids]
    conditions << "problem_objective_id IN ('#{ids[:problem_objective_ids].join("','")}')" if ids[:problem_objective_ids]
    conditions << "(output_id IN ('#{ids[:output_ids].join("','")}') OR output_id IS NULL)" if ids[:output_ids]

    query_string = conditions.join(' AND ')

    amounts = self.loaded

    amounts.where("#{query_string} AND is_deleted = false")
        .where(where).limit(limit)
  end

  # models_optimized is a much faster implementation of models but relies on postgres 9.3 or greater to generate json on
  # selection
  # ids - a hash of parameter ids that the data should belong to. For example, operation_ids => [123, 456] will get all data
  #   that belongs to either of those operations.
  # limit - limits the number of selected data
  # where - any where conditions for the query. This is vulnerable  to sql injection.
  # offset - the number to offset the data selection.
  def models_optimized(ids = {}, limit = nil, where = nil, offset = nil)
    conditions = generate_conditions ids
    query_string = conditions.join(' AND ')
    query_string = " AND #{query_string}" unless conditions.empty?

    # Need to include Strategy Objective ids
    outerSql = "select array_to_json(array_agg(row_to_json(t))) from ( "
    innerSql = "
        select #{self.public_fields.join(', ')},

          (
            select array_to_json(array_agg(row_to_json(d)::json->'strategy_objective_id'))
            from (

              #{([Goal, Output, ProblemObjective].map { |c| parameter_sql(c) }).join(' INTERSECT ')}

            ) as d
        ) as strategy_objective_ids
      from #{self.table_name}
      where is_deleted = false #{query_string}"

    innerSql += " AND (#{where})" if where.present? and !where.empty?
    innerSql += " LIMIT #{sanitize(limit)}" unless limit.nil?
    innerSql += " OFFSET #{sanitize(offset)}" unless offset.nil?

    sql = outerSql + innerSql  + ") t"

    ActiveRecord::Base.connection.execute(sql)

  end

  # Generates sql for a single parameter. This is an internal method.
  def parameter_sql(parameterClass)
    "select strategy_objective_id
    from #{parameterClass.table_name}_strategy_objectives
    inner join strategy_objectives on strategy_objectives.id = #{parameterClass.table_name}_strategy_objectives.strategy_objective_id
    inner join strategies on strategy_objectives.strategy_id = strategies.id
    where #{parameterClass.table_name.singularize}_id = #{self.table_name}.#{parameterClass.table_name.singularize}_id"
  end

  def sanitize(sql)
    ActiveRecord::Base::sanitize(sql)
  end

  def generate_conditions(ids)

    conditions = []

    conditions << "operation_id IN ('#{ids[:operation_ids].join("','")}')" if ids[:operation_ids]
    conditions << "plan_id IN ('#{ids[:plan_ids].join("','")}')" if ids[:plan_ids]
    conditions << "ppg_id IN ('#{ids[:ppg_ids].join("','")}')" if ids[:ppg_ids].present? && !ids[:ppg_ids].empty?
    conditions << "goal_id IN ('#{ids[:goal_ids].join("','")}')" if ids[:goal_ids].present? && !ids[:goal_ids].empty?
    conditions << "problem_objective_id IN ('#{ids[:problem_objective_ids].join("','")}')" if ids[:problem_objective_ids].present? && !ids[:problem_objective_ids].empty?
    conditions << "(output_id IN ('#{ids[:output_ids].join("','")}') OR output_id IS NULL)" if ids[:output_ids].present? && !ids[:output_ids].empty?

    conditions
  end

end
