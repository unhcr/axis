class Visio.Views.StrategyCMSIndexView extends Backbone.View

  template: HAML['cms/strategies/index']

  initialize: ->
    @render()

  render: ->
    @$el.html @template(strategies: @collection.toJSON())

  close: ->
    @unbind()
    @remove()
