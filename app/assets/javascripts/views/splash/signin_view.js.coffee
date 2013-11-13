class Visio.Views.SigninView extends Backbone.View

  template: JST['splash/signin']

  initialize: () ->
    @render()

  render: () ->
    @$el.html @template()
    @
