class Visio.Views.Error extends Backbone.View

  template: HAML['shared/error']

  className: 'error'

  events:
    'click .error-close': 'close'

  initialize: (options) ->
    @title = options.title
    @description = options.description
    @render()
    window.setTimeout @close.bind(@), 5000

  render: ->
    @$el.html @template { title: @title, description: @description }
    $('body').append @el

  close: ->
    @unbind()
    @remove()

