class Visio.Views.MenuView extends Backbone.View

  template: HAML['shared/menu']
  templateStrategies: HAML['shared/menu_strategies']
  templatePageList: HAML['shared/filter_system/page_list']

  tabs: [
    { type: 'strategies', human: 'Strategies', fn: 'renderStrategies' },
    { type: 'operations', human: 'Operations', fn: 'renderPages' },
    { type: 'indicators', human: 'Indicators', fn: 'renderPages' },
  ]

  initialize: (options) ->
    @tab = @tabs[0]
    @operations = new Visio.Collections.Operation()
    @indicators = new Visio.Collections.Indicator()
    @render()

  render: () ->
    @$el.html @template
      tabs: @tabs
      tab: @tab

    @[@tab.fn]()

    @

  events:
    'click .menu-tab': 'onClickMenuTab'

  renderStrategies: ->
    @$el.find('.menu-title').text ''
    @$el.find('.menu-content').html @templateStrategies
      strategies: Visio.manager.strategies().toJSON()
      personalStrategies: Visio.manager.personalStrategies().toJSON()
      sharedStrategies: Visio.manager.sharedStrategies().toJSON()

  renderPages: ->

    @$el.find('.menu-title').text @tab.human

    if @[@tab.type].length > 0
      @$el.find('.menu-content').html @templatePageList
        models: @[@tab.type].models
    else
      NProgress.start()
      @$el.find('.menu-content').html ''
      @[@tab.type].fetch().done =>
        @$el.find('.menu-content').html @templatePageList
          models: @[@tab.type].models
        NProgress.done()

  onClickMenuTab: (e) =>
    type = $(e.currentTarget).data().tab

    tab = _.find @tabs, (t) -> t.type == type

    @tab = tab
    @$el.find('.menu-tab').removeClass 'selected'
    $(e.currentTarget).addClass 'selected'
    @[tab.fn]()
