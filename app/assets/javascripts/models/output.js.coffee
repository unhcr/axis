class Visio.Models.Output extends Visio.Models.Parameter

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/outputs'

  paramRoot: 'output'

  name: Visio.Parameters.OUTPUTS.plural
