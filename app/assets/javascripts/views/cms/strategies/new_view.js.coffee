class Visio.Routers.StrategyCMSNewView extends Backbone.View

  template: JST['cms/strategies/edit']

  initialize: ->
    @render()

  render: ->
    @$el.html @template(strategy: @model.toJSON())

  save: ->
    @model.save()
