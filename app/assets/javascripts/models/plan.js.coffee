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

  strategySituationAnalysis: () ->

    if _.isEmpty Visio.manager.get('selected_strategies')
      # Just return analysis for entire plan
      return @get('situation_analysis')
    else
      # Need to calculate based on strategy data
      strategies = Visio.manager.strategies _.keys(Visio.manager.get('selected_strategies'))
      data = new Visio.Collections.IndicatorDatum()

      strategies.each (strategy) =>
        d = @strategyIndicatorData(strategy)
        data.add d.models, { silent: true }

      return data.situation_analysis()

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

  toString: () ->
    @get('operation_name')
