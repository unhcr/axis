class Visio.Models.Strategy extends Visio.Models.Syncable

  urlRoot: '/strategies'

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
    @set('operations', new Visio.Collections.Operation((options.operations || [])))
    @set('ppgs', new Visio.Collections.Ppg((options.ppgs || [])))
    @set('strategy_objectives', new Visio.Collections.StrategyObjective((options.strategy_objectives || [])))

    # Initialize helper functions
    _.each _.values(Visio.Parameters), (hash) =>
      @[hash.plural] = () =>
        ids = _.keys(@get("#{hash.singular}_ids"))
        parameters = Visio.manager.get(hash.plural)
        return new parameters.constructor(parameters.filter (model) =>
          @get("#{hash.singular}_ids")[model.id])




