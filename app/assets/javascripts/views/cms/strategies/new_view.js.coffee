class Visio.Views.StrategyCMSNewView extends Backbone.View

  template: JST['cms/strategies/edit']

  initialize: ->
    @render()

  render: ->
    form = new Backbone.Form
      model: @model
    @$el.html form.render().el

  save: ->
    @model.save()
