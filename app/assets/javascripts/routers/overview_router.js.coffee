class Visio.Routers.OverviewRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    Visio.Routers.GlobalRouter.prototype.initialize.call(@)

    selectedStrategies = {}
    selectedStrategies[Visio.manager.strategy().id] = true


    Visio.manager.set 'selected_strategies', selectedStrategies
    Visio.manager.on 'change:date', () =>
      @navigation.render()
      @strategySnapshotView.render()
      @moduleView.render true

    Visio.manager.on ['change:aggregation_type'
                      'change:selected',
                      'change:achievement_type',
                      'change:scenario_type',
                      'change:budget_type',
                      'change:amount_type'].join(' '), =>
      @moduleView.render true

    @module = $('#module')

  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    @toolbarView = new Visio.Views.ToolbarView({ el: $('.toolbar') })
    options =
      join_ids:
        strategy_id: Visio.manager.get('strategy_id')

    $.when(Visio.manager.get('ppgs').fetchSynced(options),
           Visio.manager.get('operations').fetchSynced(options),
           Visio.manager.get('goals').fetchSynced(options),
           Visio.manager.get('outputs').fetchSynced(options),
           Visio.manager.get('problem_objectives').fetchSynced(options),
           Visio.manager.get('indicators').fetchSynced(options),
           Visio.manager.get('strategy_objectives').fetch(),
           Visio.manager.get('expenditures').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
           Visio.manager.get('budgets').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
    ).done(() =>
      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      @navigation = new Visio.Views.NavigationView({
        el: $('#navigation')
      })
      @navigation.render()

      @strategySnapshotView = new Visio.Views.StrategySnapshotView(
        el: $('#strategy-snapshot')
      )
      @strategySnapshotView.render()

      $('#navigation').removeClass('gone')

      $collapsable = $('.collapsable-content')
      $collapsable.attr 'data-0', "max-height:#{$('.collapsable-content').height()}px"
      $collapsable.attr "data-#{$('.collapsable-content').height()}", "max-height:0px"
      #skrollr.init(
      #  forceHeight: false
      #)
      Visio.manager.set('setup', true)
    )


  routes:
    'menu' : 'menu'
    'search': 'search'
    'export/:figureId': 'export'
    ':figureType/:year': 'figure'
    ':figureType': 'figure'
    '*default': 'index'

  export: (figureId) ->
    unless Visio.FigureInstances[figureId]?
      @navigate '/', { trigger: true }
      return

    @setup().done =>
      figure = Visio.FigureInstances[figureId]
      config = $.extend { isExport: true }, figure.config()
      model = new Visio.Models.ExportModule
        figure_type: figure.type
        state: Visio.manager.state()
        figure_config: config

      @exportView = new Visio.Views.ExportModule( model: model)
      $('.content').append(@exportView.render().el)

  figure: (figureType, year) ->
    Visio.manager.year year, { silent: true } if year?
    @setup().done(() =>
      viewClass = figureType[0].toUpperCase() + figureType.slice(1) + 'View'

      @figureView.close() if @figureView
      @moduleView = new Visio.Views[viewClass]()

      @module.html @moduleView.render().el

      if $('header').height() < $(document).scrollTop()
        $('.toolbar').addClass('fixed-top')
    ).fail (e) =>
      console.log e

  index: () =>
    @figure('absy')

