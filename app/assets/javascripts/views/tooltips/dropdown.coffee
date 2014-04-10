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
      open: open
      title: @title
      cid: @cid
    @

  onTransitionEnd: (e) =>
    if not @isOpen() and e.originalEvent.propertyName == 'max-height'
      @$el.find('.visio-dropdown').removeClass 'styled'

  onChange: (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)

    type = $target.val().split(Visio.Constants.SEPARATOR)[0]
    attr = $target.val().split(Visio.Constants.SEPARATOR)[1]
    @callback $target.val(), $target.data() if @callback?

  isOpen: =>
    @$el.find('.visio-dropdown').hasClass 'open'

  onToggleDropdown: (e) =>
    @$el.find('.visio-dropdown').toggleClass('open')
    if @isOpen()
      @$el.find('.visio-dropdown').toggleClass('styled')

