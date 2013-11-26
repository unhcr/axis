class Visio.Models.Goal extends Backbone.Model

  constructor: () ->
    Backbone.Model.apply(@, arguments)

  urlRoot: '/goals'

  paramRoot: 'goal'



