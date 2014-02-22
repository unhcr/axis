class Visio.Routers.StrategyCMSEditView extends Backbone.View

  template: HAML['cms/strategies/edit']

  initialize: ->
    @render()

  render: ->
    @$el.html @template(strategy: @model.toJSON())

  save: ->
    @model.save()

