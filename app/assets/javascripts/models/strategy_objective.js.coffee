class Visio.Models.StrategyObjective extends Visio.Models.Parameter

  constructor: ->
    Backbone.Model.apply @, arguments

  initialize: (options) ->
    options or= {}
    @set(Visio.Parameters.GOALS.plural,
      new Visio.Collections.Goal((options[Visio.Parameters.GOALS.plural] || [])))
    @set(Visio.Parameters.PROBLEM_OBJECTIVES.plural,
      new Visio.Collections.ProblemObjective((options[Visio.Parameters.PROBLEM_OBJECTIVES.plural] || [])))
    @set(Visio.Parameters.OUTPUTS.plural,
      new Visio.Collections.Output((options[Visio.Parameters.OUTPUTS.plural] || [])))
    @set(Visio.Parameters.INDICATORS.plural,
      new Visio.Collections.Indicator((options[Visio.Parameters.INDICATORS.plural] || [])))

  name: Visio.Parameters.STRATEGY_OBJECTIVES

  urlRoot: '/strategy_objectives'

  paramRoot: 'strategy_objective'

  schema: [
    {
      name: 'name',
      type: 'string',
      formElement: 'text',
      human: 'Name'
    },
    {
      name: 'description',
      type: 'string',
      human: 'Description',
      formElement: 'textarea'
    },
    {
      name: 'goals',
      type: 'collection',
      human: 'Goals',
      formElement: 'checkboxes',
      collection: -> new Visio.Collections.Goal()
    },
    {
      name: 'problem_objectives',
      human: 'Problem Objectives',
      type: 'collection',
      formElement: 'checkboxes',
      collection: -> new Visio.Collections.ProblemObjective()
    },
    {
      name: 'outputs',
      human: 'Outputs',
      type: 'collection',
      formElement: 'checkboxes',
      collection: -> new Visio.Collections.Output()
    },
    {
      name: 'indicators',
      human: 'Indicators',
      type: 'collection',
      formElement: 'checkboxes',
      collection: -> new Visio.Collections.Indicator()
    },
  ]

  defaults:
    'name': 'Everyday'
    'description': 'Hustlin\''

  toString: ->
    @get 'name'

