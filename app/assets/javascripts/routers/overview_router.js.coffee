class Visio.Routers.OverviewRouter extends Visio.Routers.GlobalRouter

  initialize: (options) ->
    Visio.Routers.GlobalRouter.prototype.initialize.call(@)

    selectedStrategies = {}
    selectedStrategies[Visio.manager.strategy().id] = true
    Visio.manager.set 'selected_strategies', selectedStrategies
    Visio.manager.on 'change:date', () =>
      @navigation.render()
      @moduleView.render(true)

    Visio.manager.on 'change:aggregation_type', () =>
      @moduleView.render(true)

    Visio.manager.on 'change:selected', () =>
      @moduleView.render(true)

    Visio.manager.on 'change:achievement_type', () =>
      @moduleView.render(true)

    Visio.manager.on 'change:scenario_type', () =>
      @moduleView.render(true)

    Visio.manager.on 'change:budget_type', () =>
      @moduleView.render(true)

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
           Visio.manager.get('budgets').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
    ).done(() =>
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
    'isy': 'isy'
    '*default': 'index'

  isy: (skipScrollTo) ->
    @setup().done(() =>
      @indicatorSingleYearView = new Visio.Views.IndicatorSingleYearView()
      @module.html @indicatorSingleYearView.render().el
      @moduleView = @indicatorSingleYearView
      @scrollToModule() unless skipScrollTo
    ).fail (e) =>
      console.log e


  absy: (skipScrollTo) ->
    @setup().done(() =>
      @achievementBudgetSingleYearView = new Visio.Views.AchievementBudgetSingleYearView()
      @module.html @achievementBudgetSingleYearView.el
      @moduleView = @achievementBudgetSingleYearView
      @moduleView.render()
      @scrollToModule() unless skipScrollTo
    ).fail (e) =>
      console.log e

  index: () =>
    @absy(true)

  scrollToModule: () =>
    $('.toolbar').addClass('fixed-top')
