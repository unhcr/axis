class Visio.Models.Strategy extends Backbone.Model

  urlRoot: '/strategies'

  paramRoot: 'strategy'

  include: (type, id) ->

    _.include(@get("#{type}_ids"), id)

  initialize: (options) ->
    # Initialize helper functions
    _.each Visio.Types, (type) =>
      @[type] = () =>
        ids = _.keys(@get("#{type}_ids"))
        parameters = Visio.manager.get(type)
        return new parameters.constructor(parameters.filter (model) =>
          @get("#{type}_ids")[model.id])




