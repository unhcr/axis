class Visio.Routers.IndexRouter extends Backbone.Router

  initialize: (options) ->

    @map = Visio.Graphs.map(
      margin:
        top: 0
        left: 0
        right: 0
        bottom: 0
      selection: d3.select '#map'
      width: $(window).width()
      height: 500)


    Visio.manager.on('change:date', () =>
      options =
        options:
          include:
            counts: true
            situation_analysis: true
      Visio.manager.get('plans').fetchSynced(options).done(() =>
        @map.clearTooltips()
        @map()
      )
    )
    @setup()


  routes:
    ':plan_id/:type': 'list'
    '*default': 'index'

  index: () ->
    console.log 'index'

  setup: () =>

    options =
      year: Visio.manager.year()
      options:
        include:
          counts: true
          situation_analysis: true
    plans = Visio.manager.get('plans')
    plans.fetchSynced(options).done(() =>
      Visio.manager.set('plans', plans)
      Visio.manager.getMap().done((map) =>
        @map.mapJSON(map)
        @filterView = new Visio.Views.MapFilterView()
        @map()
      )
    )

  list: (plan_id, type) ->

    @listView.close() if @listView

    @listView = new Visio.Views.ParameterListView(
      model: Visio.manager.plan(plan_id)
      type: type || Visio.Parameters.INDICATORS
    )

    $('header').after(@listView.el)
