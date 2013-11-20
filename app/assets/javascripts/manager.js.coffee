class Visio.Models.Manager extends Backbone.Model

  initialize: () ->
    @getStoredOperations()


  defaults:
    'operations': []
    'date': new Date()
