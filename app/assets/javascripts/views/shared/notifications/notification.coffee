class Visio.Views.Notification extends Backbone.View

  template: HAML['shared/notifications/notification']

  events:
    'click .notification-close': 'close'

  initialize: (options) ->
    @title = options.title || ''
    @description = options.description || ''
    @render()
    window.setTimeout @close.bind(@), if _.isNumber(options.timeout) then options.timeout else 5000

  render: ->
    @$el.html @template { title: @title, description: @description }
    $('body').append @el

  close: ->
    @unbind()
    @remove()

