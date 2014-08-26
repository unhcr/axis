class Visio.Views.Dropdown extends Backbone.View

  template: HAML['tooltips/dropdown']

  className: 'visio-dropdown-container header-button'

  events:
    'change input': 'onChange'
    'click .visio-dropdown-toggle': 'onToggleDropdown'
    'transitionend .visio-dropdown': 'onTransitionEnd'
    'MSTransitionEnd .visio-dropdown': 'onTransitionEnd'
    'webkitTransitionEnd .visio-dropdown': 'onTransitionEnd'
    'oTransitionEnd .visio-dropdown': 'onTransitionEnd'

  initialize: (options) ->
    @title = options.title
    @data = options.data
    @callback = options.callback

  render: (isRerender) ->
    open = if isRerender? then @isOpen() else false
    @$el.html @template
      data: @data
      title: @title
      cid: @cid

    if open
      @$el.addClass 'open styled'
    else
      @$el.removeClass 'open styled'

    @$el.find('.visio-dropdown').on 'mouseleave', @onToggleDropdown
    @

  onTransitionEnd: (e) =>
    e.stopPropagation()
    @transitioning = false
    if not @isOpen() and e.originalEvent.propertyName == 'max-height'
      @$el.removeClass 'styled'

  onChange: (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)

    type = $target.val().split(Visio.Constants.SEPARATOR)[0]
    attr = $target.val().split(Visio.Constants.SEPARATOR)[1]
    @callback $target.val(), $target.data() if @callback?

  isOpen: =>
    @$el.hasClass 'open'

  onToggleDropdown: (e) =>
    return if @transitioning
    @transitioning = true
    @$el.toggleClass('open')
    if @isOpen()
      @$el.toggleClass('styled')

