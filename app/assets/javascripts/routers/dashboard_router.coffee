class Visio.Routers.DashboardRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    super

    Visio.manager.on 'change:date', () =>
      @navigation.render()
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    Visio.manager.on 'change:module_type', =>
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { trigger: true }

    Visio.manager.on 'change:aggregation_type', =>
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    Visio.manager.on 'change:selected', (parameterTypeChanged) =>
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    Visio.manager.on ['change:navigation'].join(' '), =>
      @navigation.render()
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    Visio.manager.on 'change:reported_type', =>
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    Visio.manager.on ['change:achievement_type',
                      'change:scenario_type',
                      'change:budget_type',
                      'change:amount_type'].join(' '), =>
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    @module = $('#module')

  routes:
    'menu' : 'menu'
    'search': 'search'
    ':figureType/:year/:aggregationType/:reportedType': 'figure'
    ':figureType/:year/:aggregationType': 'figure'
    ':figureType/:year': 'figure'
    ':figureType': 'figure'
    '*default': 'index'

  figure: (figureType, year, aggregationType, reportedType) ->
    Visio.manager.year year, { silent: true } if year?
    Visio.manager.set { 'aggregation_type': aggregationType }, { silent: true } if aggregationType?
    Visio.manager.set { 'reported_type': reportedType }, { silent: true } if reportedType?
    Visio.manager.set { 'module_type': figureType }, { silent: true } if figureType?
    @setup().done(() =>
      viewClass = figureType[0].toUpperCase() + figureType.slice(1) + 'View'

      @moduleView = new Visio.Views[viewClass]()

      @module.html @moduleView.render().el

      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }

    ).fail (e) =>
      console.log e

  index: () =>
    @figure 'absy'
