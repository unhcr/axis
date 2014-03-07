class Visio.Routers.IndexRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    super
    height = $(window).height() - $('header').height()

    @map = new Visio.Figures.Map
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      model: new Visio.Models.Map({ mapMD5: options.mapMD5 })
      width: $(window).width()
      height: height
      el: $('#map').get(0)


    Visio.manager.on 'change:selected_strategies', () =>
      @map.render()
    Visio.manager.on 'change:date', () =>
      options =
        options:
          include:
            counts: true
            situation_analysis: true
      Visio.manager.get('plans').fetchSynced(options).done () =>
        @map.clearTooltips()
        @map.collectionFn new Visio.Collections.Plan(Visio.manager.get('plans').filter (plan) ->
          plan.get('year') == Visio.manager.year())
        @map.render()
        @map.filterTooltips Visio.manager.selectedStrategyPlanIds()

    @setup()

  routes:
    'search': 'search'
    'menu': 'menu'
    ':plan_id/:type': 'list'
    '*default': 'index'

  index: ->
    console.log 'index'

  setup: =>

    options =
      where:
        year: Visio.manager.year()
      options:
        include:
          counts: true
          situation_analysis: true
    NProgress.start()
    @map.getMap().done( =>
      @filterView = new Visio.Views.MapFilterView()
      @map.render()
      Visio.manager.get('plans').fetchSynced(options)
    ).done =>
      @map.collectionFn new Visio.Collections.Plan(Visio.manager.get('plans').filter (plan) ->
        plan.get('year') == Visio.manager.year())
      @map.render()
      NProgress.done()

  list: (plan_id, type) ->

    @listView.close() if @listView

    @listView = new Visio.Views.ParameterListView(
      model: Visio.manager.plan(plan_id)
      type: type || Visio.Parameters.INDICATORS.plural
    )

    $('header').after(@listView.el)
