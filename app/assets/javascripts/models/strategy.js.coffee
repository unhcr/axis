class Visio.Models.Strategy extends Visio.Models.Data

  @include Visio.Mixins.Dashboardify

  urlRoot: '/strategies'

  name: Visio.Syncables.STRATEGIES

  schema: [
    {
      name: 'name',
      type: 'string',
      human: 'Name',
      formElement: 'text'
    },
    {
      name: 'description',
      human: 'Description',
      type: 'string',
      formElement: 'textarea'
    },
    {
      name: 'operations',
      human: 'Operations',
      formElement: 'checkboxes',
      type: 'collection',
      collection: -> new Visio.Collections.Operation()
    },
    {
      name: 'ppgs',
      human: 'PPGs',
      formElement: 'checkboxes',
      type: 'collection',
      collection: -> new Visio.Collections.Ppg()
    },
    {
      name: 'strategy_objectives',
      human: 'Strategy Objectives',
      formElement: 'list',
      type: 'collection',
      model: -> new Visio.Models.StrategyObjective(),
      collection: -> new Visio.Collections.StrategyObjective()
    }
  ]

  defaults:
    'name': 'Generic Strategy'
    'description': 'Saving lives everyday'
    'operation_ids': {}
    'ppg_ids': {}
    'output_ids': {}
    'goal_ids': {}
    'indicator_ids': {}
    'problem_objective_ids': {}
    'strategy_objective_ids': {}
    'isStrategy': true
    'is_personal': false

  include: (singular, id) ->
    @get("#{singular}_ids")[id]?

  initialize: (options) ->
    options or= {}
    @set('shared_users', new Visio.Collections.User((options.shared_users || [])))
    @set('operations', new Visio.Collections.Operation((options.operations || [])))
    @set('ppgs', new Visio.Collections.Ppg((options.ppgs || [])))
    @set('strategy_objectives', new Visio.Collections.StrategyObjective((options.strategy_objectives || [])))

