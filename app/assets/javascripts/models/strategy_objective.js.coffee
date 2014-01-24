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


  selectedData: (type) ->
    return new Visio.Collections[type.className](Visio.manager.get(type.plural).filter((d) =>
      _.include(d.get("#{Visio.Parameters.STRATEGY_OBJECTIVES.singular}_ids"), @id) and
        d.get('year') == Visio.manager.year()))

  strategyBudgetData: ->
    @selectedData(Visio.Syncables.BUDGETS)

  strategyExpenditureData: ->
    @selectedData(Visio.Syncables.EXPENDITURES)

  strategyIndicatorData: ->
    @selectedData(Visio.Syncables.INDICATOR_DATA)
