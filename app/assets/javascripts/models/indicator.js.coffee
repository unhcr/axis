class Visio.Models.Indicator extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicators'

  paramRoot: 'indicator'



