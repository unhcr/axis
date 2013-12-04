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

  situation_analysis: () ->
    # Should be calculated once in manager
    $checkedStrategies = $('.visio-check input:checked')
    if $checkedStrategies.length == 0
      # Just return analysis for entire plan
      return @get('situation_analysis')
    else
      # Need to calculate based on strategy data
      strategy_ids = $checkedStrategies.map((i, ele) -> +$(ele).val())
      strategies = Visio.manager.strategies(strategy_ids)
      Visio.manager.get('indicator_data').situation_analysis(
        plans_ids: _.intersection.apply(null, strategies.pluck('plans_ids'))
        ppgs_ids: _.intersection.apply(null, strategies.pluck('ppgs_ids'))
        goals_ids: _.intersection.apply(null, strategies.pluck('goals_ids'))
        outputs_ids: _.intersection.apply(null, strategies.pluck('outputs_ids'))
        problem_objectives_ids: _.intersection.apply(null, strategies.pluck('problem_objectives_ids'))
        indicators_ids: _.intersection.apply(null, strategies.pluck('indicators_ids'))
      )


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

