class Visio.Views.ToolbarView extends Backbone.View

  template: JST['shared/toolbar']

  initialize: (options) ->
    @render()

  render: () ->
    @$el.html @template()
    @$el.removeClass('gone')
    @
