class Visio.Routers.OverviewRouter extends Backbone.Router

  initialize: (options) ->
    @setup().done(() =>

      @navigation = new Visio.Views.NavigationView({
        el: $('#navigation')
      })
      @navigation.render()

      @strategySnapshotView = new Visio.Views.StrategySnapshotView(
        el: $('#strategy-snapshot')
      )
      @strategySnapshotView.render()

      @achievementBudgetSingleYearView = new Visio.Views.AchievementBudgetSingleYearView(
        el: $('#achievement-budget-single-year')
      )
      @achievementBudgetSingleYearView.render()
    )

  setup: () ->
    options =
      join_ids:
        strategy_id: Visio.manager.get('strategy_id')

    $.when(Visio.manager.get('plans').fetchSynced(options),
           Visio.manager.get('ppgs').fetchSynced(options),
           Visio.manager.get('goals').fetchSynced(options),
           Visio.manager.get('outputs').fetchSynced(options),
           Visio.manager.get('problem_objectives').fetchSynced(options),
           Visio.manager.get('indicators').fetchSynced(options)
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
    )


  routes:
    '*default': 'index'

  index: () ->
    console.log 'index'
