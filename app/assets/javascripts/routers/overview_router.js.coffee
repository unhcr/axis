class Visio.Routers.OverviewRouter extends Visio.Routers.DashboardRouter

  initialize: (options) ->
    super

    selectedStrategies = {}
    selectedStrategies[Visio.manager.strategy().id] = true

    Visio.manager.set 'selected_strategies', selectedStrategies


  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    options =
      join_ids:
        strategy_id: Visio.manager.get('strategy_id')

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetchSynced(options),
           Visio.manager.get('operations').fetchSynced(options),
           Visio.manager.get('goals').fetchSynced(options),
           Visio.manager.get('outputs').fetchSynced(options),
           Visio.manager.get('problem_objectives').fetchSynced(options),
           Visio.manager.get('indicators').fetchSynced(options),
           Visio.manager.get('strategy_objectives').fetch(
             { data: { where: { strategy_id: Visio.manager.get('strategy_id') } } }),
           Visio.manager.get('expenditures').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
           Visio.manager.get('budgets').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
           Visio.manager.get('indicator_data').fetchSynced({ strategy_id: Visio.manager.get('strategy_id') })
    ).done( =>

      try
        # Initialize selected to be strategy
        Visio.manager.resetSelectedDefaults()

        Visio.manager.set('setup', true)
      catch error
        new Visio.Views.Error
          title: 'Error rendering page'
          description: error

      finally
        NProgress.done()
    )

