class Visio.Views.Module extends Backbone.View

  close: ->
    @unbind()
    @remove()
