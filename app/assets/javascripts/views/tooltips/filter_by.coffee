class Visio.Views.FilterBy extends Backbone.View

  name: 'filter_by'

  template: HAML['tooltips/filter_by']

  className: 'filter-by'

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
    @$el.html @template({ figure: @figure })
    @

  onFilter: (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)
    console.log $target.val()

    type = $target.val().split(Visio.Constants.SEPARATOR)[0]
    attr = $target.val().split(Visio.Constants.SEPARATOR)[1]
    active = $target.is ':checked'

    @figure.filters.get(type).filter(attr, active)
    @figure.render()

  isOpen: =>
    @$el.find('.filters').hasClass 'open'

  onTransitionEnd: (e) =>
    if not @isOpen() and e.originalEvent.propertyName == 'max-height'
      @$el.find('.filters').removeClass 'styled'

  onToggleFilters: (e) =>
    console.log 'here'
    @$el.find('.filters').toggleClass('open')
    if @isOpen()
      @$el.find('.filters').toggleClass('styled')

  onResetFilters: (e) =>
    @figure.filters.resetFilters()
    @figure.render()
    @$el.find('input').prop 'checked', true

  close: ->
    @unbind()
    @remove()
