class Visio.Models.Strategy extends Backbone.Model

  urlRoot: '/strategies'

  paramRoot: 'strategy'

  constructor: ->

    @schema.strategy_objectives =
      type: 'List'
      itemType: 'NestedModel'
      model: Visio.Models.StrategyObjective


    Backbone.Model.apply @, arguments

  schema:
    name:
      type: 'Text'
    description:
      type: 'TextArea'
    operations:
      type: 'Checkboxes'
      options: []

  defaults:
    'name': 'Generic Strategy'
    'description': 'Saving lives everyday'
    'plan_ids': {}
    'ppg_ids': {}
    'output_ids': {}
    'goal_ids': {}
    'indicator_ids': {}
    'problem_objective_ids': {}
    'strategy_objective_ids': {}

  include: (type, id) ->

    @get("#{type}_ids")[id]?

  initialize: (options) ->
    options or= {}
    @set('operations', new Visio.Collections.Operation((options.operations || [])))

    # Initialize helper functions
    _.each _.values(Visio.Parameters), (hash) =>
      @[hash.plural] = () =>
        ids = _.keys(@get("#{hash.singular}_ids"))
        parameters = Visio.manager.get(hash.plural)
        return new parameters.constructor(parameters.filter (model) =>
          @get("#{hash.singular}_ids")[model.id])




