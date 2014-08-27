class Visio.Routers.IndexRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    super
    height = $(window).height() - $('header').height()

    @setup()

  routes:
    'search': 'search'
    'menu': 'menu'
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
    #NProgress.start()
    #@map.getMap().done( =>
    #  @filterView = new Visio.Views.MapFilterView()
    #  @map.render()

    #  Visio.manager.get('plans').fetchSynced(options).done =>
    #    @map.collectionFn new Visio.Collections.Plan(Visio.manager.get('plans').filter (plan) ->
    #      plan.get('year') == Visio.manager.year())
    #    @map.render()
    Visio.manager.set 'setup', true
    #    NProgress.done())
