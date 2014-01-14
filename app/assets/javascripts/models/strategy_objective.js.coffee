class Visio.Models.StrategyObjective extends Backbone.Model

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
    rights_groups:
      type: 'Checkboxes'
      options: (callback) =>
        callback(new Visio.Collections.RightsGroup())
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

