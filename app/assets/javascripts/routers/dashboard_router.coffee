class Visio.Routers.DashboardRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    super

    Visio.skrollr = skrollr.init
      forceHeight: false

    @documentView = new Visio.Views.Document()


    Visio.manager.on 'change:module_type', =>
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { trigger: true }
      Visio.Utils.dashboardMeta()

    Visio.manager.on 'change:filter_system', =>
      @headerView.filterSystem.render()
      @moduleView.render true

    Visio.manager.on ['change:achievement_type',
                      'change:scenario_type',
                      'change:budget_type',
                      'change:selected',
                      'change:aggregation_type',
                      'change:reported_type',
                      'change:date',
                      'change:amount_type'].join(' '), =>
      @moduleView.render true
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { silent: true }
      Visio.Utils.dashboardMeta()

    @module = $('#module')

  routes:
    'menu' : 'menu'
    'search': 'search'
    'share': 'share'
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
      Visio.Utils.dashboardMeta()

    ).fail (e) =>
      console.log e

  share: ->
    unless Visio.manager.get('setup')
      Visio.router.navigate Visio.Utils.generateOverviewUrl(), { trigger: true }
      return

    return unless Visio.manager.get('dashboard').shareable()



    $('body').append((new Visio.Views.ShareStrategy({ strategy: Visio.manager.get('dashboard') })).el)

  index: () =>
    @figure Visio.manager.get('module_type')
