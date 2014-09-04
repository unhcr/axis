class Visio.Routers.OperationRouter extends Visio.Routers.DashboardRouter

  initialize: (options) ->
    super


  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    options =
      add: true
      remove: false
      data:
        join_ids:
          operation_id: Visio.manager.get('dashboard').id

    dataOptions =
      add: true
      remove: false
      data:
        optimize: true
        filter_ids:
          operation_ids: [Visio.manager.get('dashboard').id]

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetch(options),
           Visio.manager.get('goals').fetch(options),
           Visio.manager.get('outputs').fetch(options),
           Visio.manager.get('strategy_objectives').fetch({ data: { global_only: true } })
           Visio.manager.get('problem_objectives').fetch(options),
           Visio.manager.get('indicators').fetch(options),
           Visio.manager.get('expenditures').fetch(dataOptions),
           Visio.manager.get('budgets').fetch(dataOptions),
           Visio.manager.get('indicator_data').fetch(dataOptions)
    ).done( =>
      Visio.manager.includeExternalStrategyData true

      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      Visio.manager.set 'setup', true
      NProgress.done()
    )


