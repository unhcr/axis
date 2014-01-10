class Visio.Views.StrategyCMSNewView extends Backbone.View

  template: JST['cms/strategies/edit']

  initialize: ->
    @render()

  render: ->
    form = new Backbone.Form
      model: @model

    @model.operations.fetchSynced().done =>
      form.fields.operations.editor.setOptions @model.operations.map( (o) -> o.toString() )
    @$el.html form.render().el

  save: ->
    @model.save()
