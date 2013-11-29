class Visio.Views.NavigationView extends Backbone.View

  template: JST['shared/navigation']

  initialize: () ->
    @render()

  render: () ->

    @$el.html @template()
