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
      add: true
      remove: false
      data:
        join_ids:
          strategy_id: Visio.manager.get('strategy_id')

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetch(options),
           Visio.manager.get('operations').fetch(options),
           Visio.manager.get('goals').fetch(options),
           Visio.manager.get('outputs').fetch(options),
           Visio.manager.get('problem_objectives').fetch(options),
           Visio.manager.get('indicators').fetch(options),
           Visio.manager.get('strategy_objectives').fetch(
             { data: { where: { strategy_id: Visio.manager.get('strategy_id') } } }),
           Visio.manager.get('expenditures').fetch({ data: {
             strategy_id: Visio.manager.get('strategy_id'),
           } })
           Visio.manager.get('budgets').fetch({ data: {
             strategy_id: Visio.manager.get('strategy_id'),
           } })
           Visio.manager.get('populations').fetch({ data: {
             strategy_id: Visio.manager.get('strategy_id'),
           } })
           Visio.manager.get('indicator_data').fetch({ data: {
             strategy_id: Visio.manager.get('strategy_id'),
           } })
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

