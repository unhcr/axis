class Visio.Models.Strategy extends Backbone.Model

  urlRoot: '/strategies'

  paramRoot: 'strategy'

  include: (type, id) ->

    _.include(@get("#{type}_ids"), id)

