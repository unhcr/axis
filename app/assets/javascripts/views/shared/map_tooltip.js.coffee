class Visio.Views.MapTooltipView extends Backbone.View

  template: HAML['shared/map_tooltip']

  className: 'tooltip tooltip-transition'

  initialize: (options) ->
    @point = options.point
    $('body').append(@el)
    @render()

  boundingId: 'map'

  parameters: [
    Visio.Parameters.PPGS,
    Visio.Parameters.GOALS,
    Visio.Parameters.OUTPUTS,
    Visio.Parameters.PROBLEM_OBJECTIVES,
    Visio.Parameters.INDICATORS
  ]

  boundingRect: null

  events:
    'click .tooltip-close': 'onClickClose'
    'click .count': 'onCountClick'
    'click .pin': 'onPinClick'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'
    'mouseenter .rollover': 'onEnterRollover'
    'mouseout .rollover': 'onOutRollover'

  onOutRollover: (e) ->
    @$el.find('.tooltip-content').removeClass('darken')
    @$el.find('.tooltip-close').removeClass('darken')

  onEnterRollover: (e) ->
    @$el.find('.tooltip-content').addClass('darken')
    @$el.find('.tooltip-close').addClass('darken')

  onTransitionEnd: (e) ->
    @$el.removeClass('tooltip-transition')

  onPinClick: (e) ->
    return if !@model.get('country') || @isExpanded()
    el = d3.select(".country.#{@model.get('country').iso3}")
    el.on('click')(el.datum())

  render: (isRerender) ->

    unless isRerender
      @$el.hide()

      counts = {}
      _.each @parameters, (parameter) =>
        counts[parameter.plural] = @count parameter

      @$el.html @template({
        plan: @model.toJSON()
        counts: counts
        situationAnalysisCategory: @model.strategySituationAnalysis().category
        parameters: @parameters
      })

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

  isCurrentYear: () =>
    @model.get('year') == Visio.manager.year()


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


    $content = @$el.find('.tooltip-content')
    offset = $(@point).offset()
    offset.left -= $content.width()
    offset.top -= $content.height()
    padding = 40

    filterWidth = $('.map-filters').width()

    @boundingRect ||= document.getElementById(@boundingId).getBoundingClientRect()

    dy = 0
    dx = 0
    if @boundingRect.top > (offset.top - padding)
      dy = @boundingRect.top - (offset.top - padding)

    if @boundingRect.left > (offset.left - padding - filterWidth)
      dx = @boundingRect.left - (offset.left - padding - filterWidth)

    if @boundingRect.right < offset.left + $content.width() + padding
      dx = @boundingRect.right - (offset.left + $content.width() + padding)

    Visio.router.map.pan dx, dy

    @render(true)

  shrink: ()->
    @$el.find('.tooltip-content').addClass('gone')
    @$el.find('.pin').removeClass('pin-extra-large')
    @render(true)

  count: (type) ->
    selectedStrategies = Visio.manager.get 'selected_strategies'
    if _.isEmpty selectedStrategies
      @model.get "#{type.plural}_count"
    else
      strategies = Visio.manager.strategies _.keys(selectedStrategies)
      ids = []
      strategies.each (strategy) ->
        ids = _.union ids, _.keys(strategy.get("#{type.singular}_ids"))

      ids = _.intersection ids, @model.get("#{type.singular}_ids")
      ids.length


  isShrunk: () ->
    return @$el.find('.tooltip-content').hasClass('gone')

  isExpanded: () ->
    return !@$el.find('.tooltip-content').hasClass('gone')

  hide: () ->
    @shrink()
    @$el.addClass('gone')
    @$el.addClass('tooltip-transition')

  show: () ->
    @$el.removeClass('gone')

  close: ()->
    @unbind()
    @remove()

  onClickClose: (e) =>
    e.stopPropagation()
    @shrink()

  onCountClick: (e) =>
    e.stopPropagation()
    @shrink()
