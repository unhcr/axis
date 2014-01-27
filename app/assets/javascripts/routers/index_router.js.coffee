class Visio.Routers.IndexRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    Visio.Routers.GlobalRouter.prototype.initialize.call(@)
    height = $(window).height() - $('header').height()

    @map = Visio.Figures.map(
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      selection: d3.select '#map'
      width: $(window).width()
      height: height)


    Visio.manager.on 'change:date', () =>
      options =
        options:
          include:
            counts: true
            situation_analysis: true
      Visio.manager.get('plans').fetchSynced(options).done () =>
        @map.clearTooltips()
        @map()
        @map.filterTooltips Visio.manager.selectedStrategyPlanIds()

    @setup()

  routes:
    'search': 'search'
    'menu': 'menu'
    ':plan_id/:type': 'list'
    '*default': 'index'

  index: () ->
    console.log 'index'

  setup: () =>

    options =
      where:
        year: Visio.manager.year()
      options:
        include:
          counts: true
          situation_analysis: true
    #NProgress.start()
    Visio.manager.getMap().done((map) =>
      @map.mapJSON(map)
      @filterView = new Visio.Views.MapFilterView()
      @map()
      Visio.manager.get('plans').fetchSynced(options)
    ).done =>
      @map()

  list: (plan_id, type) ->

    @listView.close() if @listView

    @listView = new Visio.Views.ParameterListView(
      model: Visio.manager.plan(plan_id)
      type: type || Visio.Parameters.INDICATORS.plural
    )

    $('header').after(@listView.el)
