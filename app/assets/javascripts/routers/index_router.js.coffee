class Visio.Routers.IndexRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    super
    height = $(window).height() - $('header').height()

    @map = new Visio.Figures.Map(
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      width: $(window).width()
      height: height
      el: '#map')

    Visio.manager.on 'change:date', () =>
      options =
        options:
          include:
            counts: true
            situation_analysis: true
      Visio.manager.get('plans').fetchSynced(options).done () =>
        @map.clearTooltips()
        @map.render()
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
          ppg_ids: true
          goal_ids: true
          output_ids: true
          problem_objective_ids: true
          indicator_ids: true
    #NProgress.start()
    Visio.manager.getMap().done((map) =>
      @map.modelFn new Backbone.Model map
      @filterView = new Visio.Views.MapFilterView()
      @map.render()
      Visio.manager.get('plans').fetchSynced(options)
    ).done =>
      @map.render()

  list: (plan_id, type) ->

    @listView.close() if @listView

    @listView = new Visio.Views.ParameterListView(
      model: Visio.manager.plan(plan_id)
      type: type || Visio.Parameters.INDICATORS.plural
    )

    $('header').after(@listView.el)
