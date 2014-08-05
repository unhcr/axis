class Visio.Views.Header extends Backbone.View

  template: HAML['shared/header']

  initialize: ->
    @render()

  render: ->
    @$el.html @template()
