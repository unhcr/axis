class Visio.Models.StrategyObjective extends Backbone.Model

  constructor: ->
    @problemObjectives = new Visio.Collections.ProblemObjective()
    @outputs = new Visio.Collections.Output()
    @goals = new Visio.Collections.Goal()
    @indicators = new Visio.Collections.Indicator()

    Backbone.Model.apply @, arguments

  urlRoot: '/strategy_objectives'

  paramRoot: 'strategy_objective'

  defaults:
    'name': ''
    'description': ''