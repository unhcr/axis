class Visio.Models.StrategyObjective extends Visio.Models.Parameter

  constructor: ->
    Backbone.Model.apply @, arguments

  initialize: (options) ->
    @set(Visio.Parameters.GOALS.plural,
      new Visio.Collections.Goal((options[Visio.Parameters.GOALS.plural] || [])))
    @set(Visio.Parameters.PROBLEM_OBJECTIVES.plural,
      new Visio.Collections.ProblemObjective((options[Visio.Parameters.PROBLEM_OBJECTIVES.plural] || [])))
    @set(Visio.Parameters.OUTPUTS.plural,
      new Visio.Collections.Output((options[Visio.Parameters.OUTPUTS.plural] || [])))
    @set(Visio.Parameters.INDICATORS.plural,
      new Visio.Collections.Indicator((options[Visio.Parameters.INDICATORS.plural] || [])))

  urlRoot: '/strategy_objectives'

  paramRoot: 'strategy_objective'

  schema:
    name:
      type: 'Text'
    description:
      type: 'TextArea'
    goals:
      type: 'Checkboxes'
      options: (callback) =>
        callback(new Visio.Collections.Goal())
    problem_objectives:
      type: 'Checkboxes'
      options: (callback) ->
        callback(new Visio.Collections.ProblemObjective())
    outputs:
      type: 'Checkboxes'
      options: (callback) ->
        callback(new Visio.Collections.Output())
    indicators:
      type: 'Checkboxes'
      options: (callback) ->
        callback(new Visio.Collections.Indicator())

  defaults:
    'name': ''
    'description': ''

  toString: ->
    @get 'name'

  selectedIndicatorData: ->
    return new Visio.Collections.IndicatorDatum(Visio.manager.get('indicator_data').filter((d) =>
      _.include(d.get("#{Visio.Parameters.STRATEGY_OBJECTIVES.singular}_ids"), @id) and
        d.get('year') == Visio.manager.year()))

  strategyIndicatorData: ->
    @selectedIndicatorData()

  selectedBudgetData: ->
    return new Visio.Collections.Budget(Visio.manager.get('budgets').filter((d) =>
      _.include(d.get("#{Visio.Parameters.STRATEGY_OBJECTIVES.singular}_ids"), @id) and
        d.get('year') == Visio.manager.year()))

  strategyBudgetData: ->
    @selectedBudgetData()
