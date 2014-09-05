class Visio.Views.Header extends Backbone.View

  template: HAML['shared/header']

  templateBreadcrumb: HAML['shared/header_breadcrumb']

  templateMenuValue: HAML['shared/menu_value']
  templateMenuLabel: HAML['shared/menu_label']

  events:
    'click .menu-option': 'onClickMenuOption'
    'click .menu-icon': 'onClickMenuIcon'
    'mouseleave': 'onMouseleave'
    'transitionend .menu-value': 'onTransitionEnd'
    'MSTransitionEnd .menu-value': 'onTransitionEnd'
    'webkitTransitionEnd .menu-value': 'onTransitionEnd'
    'oTransitionEnd .menu-value': 'onTransitionEnd'
    'click .menu-value': 'onChangeMenuValue'

  initialize: ->

    defaultFilterSystem = if Visio.manager.get('dashboard')?
        _.findWhere Visio.Views.FilterSystemView.OPTIONS, { type: 'filters' }
      else
        _.findWhere Visio.Views.FilterSystemView.OPTIONS, { type: 'operations' }

    # Render filter system once page is setup
    Visio.manager.on 'change:setup', =>
      if Visio.manager.get 'setup'
        @filterSystem = new Visio.Views.FilterSystemView el: $('#filter-system')
        @filterSystem.render defaultFilterSystem.type

    @menuOptions =
      module_type:
        human: 'DASHBOARDS'
        values: [Visio.FigureTypes.ICMY, Visio.FigureTypes.ISY, Visio.FigureTypes.BSY, Visio.FigureTypes.MAP
                 Visio.FigureTypes.BMY, Visio.FigureTypes.ABSY, Visio.FigureTypes.OVERVIEW]
        key: 'module_type'
        currentValue: -> Visio.manager.get('module_type')
        currentHuman: -> Visio.Utils.figureTypeByName(Visio.manager.get('module_type')).human

      reported_type:
        human: 'REPORT TYPE'
        values: [{ human: 'YER', name: Visio.Algorithms.REPORTED_VALUES.yer },
                 { human: 'MYR', name: Visio.Algorithms.REPORTED_VALUES.myr }]
        key: 'reported_type'
        currentValue: -> Visio.manager.get('reported_type')
        currentHuman: -> Visio.manager.get('reported_type').toUpperCase()

      aggregation_type:
        human: 'AGGREGATE'
        values: [Visio.Parameters.OPERATIONS, Visio.Parameters.PPGS, Visio.Parameters.GOALS,
                 Visio.Parameters.PROBLEM_OBJECTIVES, Visio.Parameters.OUTPUTS,
                 Visio.Parameters.STRATEGY_OBJECTIVES]
        key: 'aggregation_type'
        currentValue: -> Visio.manager.get('aggregation_type')
        currentHuman: -> Visio.Utils.parameterByName(Visio.manager.get('aggregation_type')).human

      year:
        human: 'YEAR'
        values: _.map Visio.manager.get('yearList'), (year) -> { human: year, name: year }
        key: 'year'
        currentValue: -> Visio.manager.year()
        currentHuman: -> Visio.manager.year()

    @render()

  render: ->
    @$el.html @template
      menuOptions: @menuOptions

    @settings?.close()
    @settings = new Visio.Views.Settings
      model: Visio.user
    @$el.find('.user-account').html @settings.render().el

    @$el.removeClass 'breadcrumb'
    open = if @filterSystem? then @filterSystem.isOpen() else false
    d3.select(@el).classed 'filter-open', open
    @

  renderBreadcrumb: ->
    @$el.html @templateBreadcrumb
      menuOptions: @menuOptions

    @$el.addClass 'breadcrumb'
    open = if @filterSystem? then @filterSystem.isOpen() else false
    d3.select(@el).classed 'filter-open', open

    @

  isBreadcrumb: ->
    @$el.hasClass 'breadcrumb'

  openOptionMenu: =>
    $optionMenu = @$el.find '.option-menu'
    $optionMenu.removeClass 'zero-max-height'
    $optionMenu.removeClass 'no-border'

  closeOptionMenu: =>
    $optionMenu = @$el.find '.option-menu'
    $optionMenu.addClass 'zero-max-height'
    $optionMenu.addClass 'no-border'
    @markOld()
    @clearMenuValues()
    $optionMenu.html ''

    # Cause a redraw
    $optionMenu[0].height = $optionMenu[0].height

  isOpenOptionMenu: =>
    $optionMenu = @$el.find '.option-menu'
    not $optionMenu.hasClass 'zero-max-height'

  swipeInMenuValues: =>
    $menuValues = @$el.find('.menu-value').not('.old')
    $menuValues.css 'left', 0

  clearMenuValues: =>
    $menuValues = @$el.find '.menu-value.old'
    $menuValues.unbind()
    $menuValues.remove()

  markOld: =>
    $menuValues = @$el.find '.menu-value'
    $menuValues.addClass 'old'

  onTransitionEnd: (e) =>
    if e.originalEvent.propertyName == 'left'
      @clearMenuValues()
      @swipeInMenuValues()

  swipeOutMenuValues: =>
    $menuValues = @$el.find '.menu-value'
    $menuValues.css 'left', '-2000px'
    @markOld()

  onClickMenuIcon: (e) =>
    @$el.toggleClass 'filter-open'
    @filterSystem.toggleState()
    $('#navigation').removeClass('gone')

  onMouseleave: (e) =>

    opened = @isOpenOptionMenu()
    if opened
      @$el.find('.menu-option').removeClass 'selected'
      @closeOptionMenu()

  onClickMenuOption: (e) ->
    $target = $(e.currentTarget)
    $optionMenu = @$el.find '.option-menu'

    # Don't bother if the item clicked isn't a menu option
    data = $target.data()
    option = @menuOptions[data.option]
    return unless option?

    opened = @isOpenOptionMenu()

    if $target.hasClass('selected') and opened
      @$el.find('.menu-option').removeClass 'selected'
      @closeOptionMenu()
      return
    else
      @$el.find('.menu-option').removeClass 'selected'
      $target.addClass 'selected'
      @openOptionMenu()


    if opened
      @swipeOutMenuValues()

    isBreadcrumb = @isBreadcrumb()

    if isBreadcrumb
      $optionMenu.find('.menu-title').remove()
      $optionMenu.append @templateMenuLabel { title: option.human }


    _.each option.values, (value) =>
      $optionMenu.append @templateMenuValue { value: value, option: option, isBreadcrumb: isBreadcrumb }

    if not opened
      @swipeInMenuValues()

  onChangeMenuValue: (e) =>
    $target = $(e.currentTarget)
    data = $target.data()

    @$el.find('.menu-value').removeClass 'selected'
    $target.addClass 'selected'

    Visio.manager.set data.key, data.value

  close: =>
    @filterSystem?.close()
    @unbind()
    @remove()
