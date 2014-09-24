class Visio.Views.Document extends Backbone.View

  initialize: ->
    fn = _.throttle @onScroll, 100

    $(document).on 'scroll', fn

    # HOT KEYS
    #
    # Toggle filters
    $(document).on 'keydown', null, 'f', @onFKey

    # Rotate through aggregation types
    $(document).on 'keydown', null, 'a', @onAKey
    $(document).on 'keydown', null, 'shift+a', @onShiftAKey

    # Rotate through years
    $(document).on 'keydown', null, 'y', @onYKey
    $(document).on 'keydown', null, 'shift+y', @onShiftYKey

    # Rotate through reported types
    $(document).on 'keydown', null, 'r', @onRKey
    $(document).on 'keydown', null, 'shift+r', @onRKey

    # Rotate through dashboards types
    $(document).on 'keydown', null, 'n', @onNKey
    $(document).on 'keydown', null, 'shift+n', @onShiftNKey

    # Overview dashboard
    $(document).on 'keydown', null, 'o', @onOKey
    # Map dashboard
    $(document).on 'keydown', null, 'm', @onMKey
    # ICMY dashboard
    $(document).on 'keydown', null, 'c', @onCKey
    # Indicators dashboard
    $(document).on 'keydown', null, 'i', @onIKey
    # BSY dashboard
    $(document).on 'keydown', null, 'b', @onBKey
    # BMY dashboard
    $(document).on 'keydown', null, 't', @onTKey
    # ABSY dashboard
    $(document).on 'keydown', null, 'g', @onGKey

  onNKey: ->
    currIdx = 0
    current = _.find Visio.Dashboards, (type, idx) ->
      currIdx = idx
      type.name == Visio.manager.get 'module_type'

    currIdx = if currIdx + 1 >= Visio.Dashboards.length then 0 else currIdx + 1

    Visio.manager.set 'module_type', Visio.Dashboards[currIdx].name

  onShiftNKey: ->
    currIdx = 0
    current = _.find Visio.Dashboards, (type, idx) ->
      currIdx = idx
      type.name == Visio.manager.get 'module_type'

    currIdx = if currIdx - 1 < 0 then Visio.Dashboards.length - 1 else currIdx - 1

    Visio.manager.set 'module_type', Visio.Dashboards[currIdx].name

  onOKey: ->
    Visio.router.navigate Visio.FigureTypes.OVERVIEW.name, { trigger: true }

  onMKey: ->
    Visio.router.navigate Visio.FigureTypes.MAP.name, { trigger: true }

  onCKey: ->
    Visio.router.navigate Visio.FigureTypes.ICMY.name, { trigger: true }

  onIKey: ->
    Visio.router.navigate Visio.FigureTypes.ISY.name, { trigger: true }

  onBKey: ->
    Visio.router.navigate Visio.FigureTypes.BSY.name, { trigger: true }

  onTKey: ->
    Visio.router.navigate Visio.FigureTypes.BMY.name, { trigger: true }

  onGKey: ->
    Visio.router.navigate Visio.FigureTypes.ABSY.name, { trigger: true }

  onFKey: ->
    $.publish 'toggle-filter-state'

  onAKey: ->
    currIdx = 0
    current = _.find Visio.AggregationTypes, (type, idx) ->
      currIdx = idx
      type.name == Visio.manager.get 'aggregation_type'

    currIdx = if currIdx + 1 >= Visio.AggregationTypes.length then 0 else currIdx + 1

    Visio.manager.set 'aggregation_type', Visio.AggregationTypes[currIdx].name

  onShiftAKey: ->
    currIdx = 0
    current = _.find Visio.AggregationTypes, (type, idx) ->
      currIdx = idx
      type.name == Visio.manager.get 'aggregation_type'

    currIdx = if currIdx - 1 < 0 then Visio.AggregationTypes.length - 1 else currIdx - 1

    Visio.manager.set 'aggregation_type', Visio.AggregationTypes[currIdx].name

  onRKey: ->
    if Visio.manager.get('reported_type') == Visio.Algorithms.REPORTED_VALUES.myr
      Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.yer
    else
      Visio.manager.set 'reported_type', Visio.Algorithms.REPORTED_VALUES.myr

  onYKey: ->
    currYear = Visio.manager.year()

    newYear = currYear + 1

    if Visio.manager.get('yearList').indexOf(newYear) == -1
      newYear = Visio.manager.get('yearList')[0]

    Visio.manager.year newYear

  onShiftYKey: ->
    currYear = Visio.manager.year()

    newYear = currYear - 1

    if Visio.manager.get('yearList').indexOf(newYear) == -1
      newYear = Visio.manager.get('yearList')[Visio.manager.get('yearList').length - 1]

    Visio.manager.year newYear

  onScroll: (e) ->
    scrollTop = $(window).scrollTop()
    if $('.inner-content').length
      offset = Visio.skrollr.relativeToAbsolute($('.inner-content')[0], 'top', 'top')
    bottomOffset = 300

    headerView = Visio.router.headerView

    if scrollTop > offset and !headerView.isBreadcrumb()
      headerView.renderBreadcrumb()
    else if scrollTop <= offset and headerView.isBreadcrumb()
      headerView.render()

    if scrollTop + $(window).height() + bottomOffset > $(document).height()
      $.publish('scroll.bottom')
  close: ->
    @unbind()
