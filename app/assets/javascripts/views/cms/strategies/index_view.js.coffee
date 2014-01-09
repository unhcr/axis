class Visio.Views.StrategyCMSIndexView extends Backbone.View

  template: JST['cms/strategies/index']

  initialize: ->
    @render()

  render: ->
    @$el.html @template(strategies: @collection.toJSON())
