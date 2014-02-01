class Visio.Models.Plan extends Visio.Models.Syncable

  initialize: (attrs, options) ->
    @set(
      indicators: new Visio.Collections.Indicator(attrs.indicators)
      outputs: new Visio.Collections.Output(attrs.outputs)
      problem_objectives: new Visio.Collections.ProblemObjective(attrs.problem_objectives)
      ppgs: new Visio.Collections.Ppg(attrs.ppgs)
      goals: new Visio.Collections.Goal(attrs.goals)
    )

  name: Visio.Syncables.PLANS

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

      return data.situationAnalysis()

  fetchParameter: (type) ->

    options =
      join_ids:
        plan_id: @id
    @get(type).fetch(data: options)

  toString: () ->
    @get('operation_name')

  getPlanForDifferentYear: (year) ->
    return @ if @get('year') == year

    operation = Visio.manager.get('operations').get(@get('operation_id'))
    plan = null
    _.each operation.get('plan_ids'), (id) =>
      p = Visio.manager.get(@name).get(id)
      plan = p if p.get('year') == year
    return plan

  refId: ->
    @get('operation_id')
