class Visio.Models.Indicator extends Visio.Models.Parameter

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/indicators'

  paramRoot: 'indicator'

  name: Visio.Parameters.INDICATORS

