class Visio.Models.Strategy extends Backbone.Model

  urlRoot: '/strategies'

  paramRoot: 'strategy'

  constructor: ->
    @operations = new Visio.Collections.Operation()
    @strategyObjectives = new Visio.Collections.StrategyObjective()

    Backbone.Model.apply @, arguments

  schema:
    name:
      type: 'Text'
    description:
      type: 'TextArea'
    operations:
      type: 'Checkboxes'
      options: []
    strategyObjectives:
      type: 'List'
      itemType: 'NestedModel'
      model: Visio.Models.StrategyObjective

  include: (type, id) ->

    @get("#{type}_ids")[id] != undefined

  initialize: (options) ->
    # Initialize helper functions
    _.each _.values(Visio.Parameters), (hash) =>
      @[hash.plural] = () =>
        ids = _.keys(@get("#{hash.singular}_ids"))
        parameters = Visio.manager.get(hash.plural)
        return new parameters.constructor(parameters.filter (model) =>
          @get("#{hash.singular}_ids")[model.id])




