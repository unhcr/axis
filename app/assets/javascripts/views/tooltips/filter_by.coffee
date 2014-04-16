class Visio.Views.FilterBy extends Backbone.View

  name: 'filter_by'

  template: HAML['tooltips/filter_by']

  className: 'filter-by header-button'

  events:
    'change input': 'onFilter'
    'click .filter-toggle': 'onToggleFilters'
    'click .reset-filters': 'onResetFilters'
    'transitionend .filters': 'onTransitionEnd'
    'MSTransitionEnd .filters': 'onTransitionEnd'
    'webkitTransitionEnd .filters': 'onTransitionEnd'
    'oTransitionEnd .filters': 'onTransitionEnd'

  initialize: (options) ->
    @figure = options.figure

  render: (isRerender) ->
    open = if isRerender? then @isOpen() else false
    @$el.html @template({ figure: @figure, open: open })

    @$el.find('.filters').on 'mouseleave', @onToggleFilters
    @

  onFilter: (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)

    type = $target.val().split(Visio.Constants.SEPARATOR)[0]
    attr = $target.val().split(Visio.Constants.SEPARATOR)[1]
    active = $target.is ':checked'

    @figure.filters.get(type).filter(attr, active)
    @figure.render true

  isOpen: =>
    @$el.find('.filters').hasClass 'open'

  onTransitionEnd: (e) =>
    if not @isOpen() and e.originalEvent.propertyName == 'max-height'
      @$el.find('.filters').removeClass 'styled'

  onToggleFilters: (e) =>
    @$el.find('.filters').toggleClass('open')
    if @isOpen()
      @$el.find('.filters').toggleClass('styled')

  onResetFilters: (e) =>
    @figure.filters.resetFilters()
    @figure.render true
    @render true

  close: ->
    @unbind()
    @remove()
