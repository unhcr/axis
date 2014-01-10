class Visio.Models.StrategyObjective extends Backbone.Model

  constructor: ->
    @problemObjectives = new Visio.Collections.ProblemObjective()
    @outputs = new Visio.Collections.Output()
    @goals = new Visio.Collections.Goal()
    @indicators = new Visio.Collections.Indicator()

    Backbone.Model.apply @, arguments

  urlRoot: '/strategy_objectives'

  paramRoot: 'strategy_objective'

  schema:
    name:
      type: 'Text'
    description:
      type: 'TextArea'
    goals:
      type: 'Checkboxes'
      options: (callback) ->
        goals = new Visio.Collections.Goal()
        goals.fetchSynced().done ->
          callback(goals)
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
