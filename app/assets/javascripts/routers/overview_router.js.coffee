class Visio.Routers.OverviewRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    Visio.Routers.GlobalRouter.prototype.initialize.call(@)

    selectedStrategies = {}
    selectedStrategies[Visio.manager.strategy().id] = true


    Visio.manager.set 'selected_strategies', selectedStrategies
    Visio.manager.on 'change:date', () =>
      # Need to get select plans from next year
      oldPlans = Visio.manager.selected('plans')
      newPlans = oldPlans.getPlansForDifferentYear(Visio.manager.year())
      ids = newPlans.pluck 'id'

      Visio.manager.get('selected')['plans'] = _.object ids, ids.map -> true

      @navigation.render()
      @strategySnapshotView.render()
      @moduleView.render(true)

    Visio.manager.on 'change:aggregation_type', () =>
      @moduleView.render true

    Visio.manager.on 'change:selected', () =>
      @moduleView.render true

    Visio.manager.on 'change:achievement_type', () =>
      @moduleView.render true

    Visio.manager.on 'change:scenario_type', () =>
      @moduleView.render true

    Visio.manager.on 'change:budget_type', () =>
      @moduleView.render true

    Visio.manager.on 'change:amount_type', =>
      @moduleView.render true

    @module = $('#module')

  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    @toolbarView = new Visio.Views.ToolbarView({ el: $('.toolbar') })
    options =
      join_ids:
        strategy_id: Visio.manager.get('strategy_id')

    $.when(Visio.manager.get('plans').fetchSynced(_.extend({}, options, {
       options:
         include:
           counts: true
           situation_analysis: true
     })),
           Visio.manager.get('ppgs').fetchSynced(options),
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
    'absy': 'absy'
    'absy/:year': 'absy'
    'isy': 'isy'
    'isy/:year': 'isy'
    'export/:figure/:figureId': 'export'
    '*default': 'index'

  export: (figure, figureId) ->
    @navigation '/', { trigger: true } unless Visio.FigureInstances[figureId]?
    @setup().done =>
      model = new Visio.Models.ExportModule
        figure: Visio.Figures[figure]
        state: Visio.manager.state()
        data: Visio.FigureInstances[figureId].data()

      @exportView = new Visio.Views.ExportModule( model: model)
      $('.content').append(@exportView.el)

  isy: (year) ->
    Visio.manager.year year, { silent: true } if year?

    @setup().done(() =>
      @indicatorSingleYearView = new Visio.Views.IndicatorSingleYearView()
      @module.html @indicatorSingleYearView.render().el
      @moduleView = @indicatorSingleYearView

      if $('header').height() < $(document).scrollTop()
        $('.toolbar').addClass('fixed-top')
    ).fail (e) =>
      console.log e


  absy: (year) ->
    Visio.manager.year year, { silent: true } if year?

    @setup().done(() =>
      @achievementBudgetSingleYearView = new Visio.Views.AchievementBudgetSingleYearView()
      @module.html @achievementBudgetSingleYearView.el
      @moduleView = @achievementBudgetSingleYearView
      @moduleView.render()

      if $('header').height() < $(document).scrollTop()
        $('.toolbar').addClass('fixed-top')
    ).fail (e) =>
      console.log e

  index: () =>
    @absy()

