class Visio.Models.Plan extends Visio.Models.Parameter

  initialize: (attrs, options) ->
    @set(
      indicators: new Visio.Collections.Indicator(attrs.indicators)
      outputs: new Visio.Collections.Output(attrs.outputs)
      problem_objectives: new Visio.Collections.ProblemObjective(attrs.problem_objectives)
      ppgs: new Visio.Collections.Ppg(attrs.ppgs)
      goals: new Visio.Collections.Goal(attrs.goals)
    )

  name: Visio.Parameters.PLANS

  urlRoot: '/plans'

  paramRoot: 'plan'

  strategy_situation_analysis: () ->
    # Should be calculated once in manager
    $checkedStrategies = $('.visio-check input:checked')
    if $checkedStrategies.length == 0
      # Just return analysis for entire plan
      return @get('situation_analysis')
    else
      # Need to calculate based on strategy data
      strategy_ids = $checkedStrategies.map((i, ele) -> +$(ele).val())
      strategies = Visio.manager.strategies(strategy_ids)

      ids =
        plans_ids: _.intersection([@id], _.intersection.apply(null, strategies.pluck('plans_ids')))
        ppgs_ids: _.intersection.apply(null, strategies.pluck('ppgs_ids'))
        goals_ids: _.intersection.apply(null, strategies.pluck('goals_ids'))
        outputs_ids: _.intersection.apply(null, strategies.pluck('outputs_ids'))
        problem_objectives_ids: _.intersection.apply(null, strategies.pluck('problem_objectives_ids'))
        indicators_ids: _.intersection.apply(null, strategies.pluck('indicators_ids'))

      data = new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((datum) ->
          return _.include(ids.plans_ids, datum.get('plan_id')) &&
            _.include(ids.ppgs_ids, datum.get('ppg_id')) &&
            _.include(ids.goals_ids, datum.get('goal_id')) &&
            _.include(ids.outputs_ids, datum.get('output_id')) &&
            _.include(ids.problem_objectives_ids, datum.get('problem_objective_id')) &&
            _.include(ids.indicators_ids, datum.get('indicator_id')) &&
            !datum.get('is_performance')
        ))

      data.situation_analysis()

  budget: () ->
    data = new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').where({ plan_id: @id }))

    problem_objective_ids = _.uniq(data.pluck('problem_objective_id'))

    problem_objectives = Visio.manager.get('problem_objectives').filter((p) ->
      _.include(problem_objective_ids, p.id) )

    _.reduce(problem_objectives,
      (sum, p) -> return sum + p.get('budget'),
      0)

  fetchIndicators: () ->
    @fetchParameter(Visio.Parameters.INDICATORS)

  fetchPpgs: () ->
    @fetchParameter(Visio.Parameters.PPGS)

  fetchOutputs: () ->
    @fetchParameter(Visio.Parameters.OUTPUTS)

  fetchProblemObjectives: () ->
    @fetchParameter(Visio.Parameters.PROBLEM_OBJECTIVES)

  fetchGoals: () ->
    @fetchParameter(Visio.Parameters.GOALS)

  fetchParameter: (type) ->

    options =
      join_ids:
        plan_id: @id
    $.get("/#{type}", options
    ).then((parameters) =>
      # Never any sync date so it'll only have new ones
      @get(type).reset(parameters.new)

      @setSynced()
    )

