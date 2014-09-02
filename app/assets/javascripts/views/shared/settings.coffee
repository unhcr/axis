class Visio.Views.Settings extends Backbone.View

  template: HAML['shared/settings']

  openClass: 'open'

  className: 'settings'

  events:
    'click .gear-icon': 'onClickGear'

  render: ->
    @$el.html @template
      model: @model

    @

  isOpen: ->
    @$el.hasClass @openClass

  onClickGear: (e) ->
    if @isOpen()
      @hide()
    else
      @open()

  open: ->
    @$el.addClass @openClass

  hide: ->
    @$el.removeClass @openClass

  close: ->
    @unbind()
    @remove()
