class Visio.Views.MapTooltipView extends Backbone.View

  template: JST['shared/map_tooltip']

  className: 'tooltip tooltip-transition'

  initialize: (options) ->
    @point = options.point
    @render()

  boundingId: 'map'

  boundingRect: null

  events:
    'click .tooltip-close': 'onClickClose'
    'click .count': 'onCountClick'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  onTransitionEnd: (e) ->
    @$el.removeClass('tooltip-transition')

  render: (isRerender) ->

    unless isRerender
      @$el.hide()
      @$el.html @template({ plan: @model.toJSON() })
      $('body').append(@el)

    offset = $(@point).offset()
    offset.left -= @$el.width() / 2
    offset.top -= @$el.height()

    if (@inBounds(offset))

      @$el.css(
        left: (offset.left)+ 'px'
        top: (offset.top) + 'px'
      )

      @$el.show()
    else
      @$el.hide()


    @

  inBounds: (offset) =>

    bounds = true

    @boundingRect ||= document.getElementById(@boundingId).getBoundingClientRect()

    if @boundingRect.top > offset.top
      bounds = false

    if @boundingRect.bottom < offset.top + @$el.height()
      bounds = false

    if @boundingRect.left > offset.left
      bounds = false

    if @boundingRect.right < offset.left + @$el.width()
      bounds = false

    bounds

  expand: () ->
    @$el.find('.tooltip-content').removeClass('gone')
    @$el.find('.pin').addClass('pin-extra-large')
    @render(true)

  shrink: ()->
    @$el.find('.tooltip-content').addClass('gone')
    @$el.find('.pin').removeClass('pin-extra-large')
    @render(true)

  isShrunk: () ->
    return @$el.find('.tooltip-content').hasClass('gone')

  isExpanded: () ->
    return !@$el.find('.tooltip-content').hasClass('gone')

  hide: () ->
    @$el.addClass('gone')

  show: () ->
    @$el.removeClass('gone')

  close: ()->
    @unbind()
    @remove()

  onClickClose: (e) =>
    @shrink()

  onCountClick: (e) =>
    @shrink()
