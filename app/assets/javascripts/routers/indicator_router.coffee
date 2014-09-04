class Visio.Routers.IndicatorRouter extends Visio.Routers.DashboardRouter

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
          indicator_id: Visio.manager.get('indicator').id

    dataOptions =
      add: true
      remove: false
      data:
        optimize: true
        filter_ids:
          indicator_ids: [Visio.manager.get('indicator').id]

    if Visio.manager.get('indicator').get 'is_performance'
      dataOptionsExpBudget =
        add: true
        remove: false
        data:
          optimize: true
          filter_ids:
            output_ids: [Visio.manager.get('dashboard').id]
    else
      dataOptionsExpBudget =
        add: true
        remove: false
        data:
          optimize: true
          filter_ids:
            problem_objective_ids: [Visio.manager.get('dashboard').id]

    Visio.manager.get('indicators').reset [Visio.manager.get('indicator')]

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetch(options),
           Visio.manager.get('goals').fetch(options),
           Visio.manager.get('outputs').fetch(options),
           Visio.manager.get('strategy_objectives').fetch({ data: { global_only: true } })
           Visio.manager.get('problem_objectives').fetch(options),
           Visio.manager.get('operations').fetch(options),
           Visio.manager.get('expenditures').fetch(dataOptionsExpBudget),
           Visio.manager.get('budgets').fetch(dataOptionsExpBudget),
           Visio.manager.get('indicator_data').fetch(dataOptions)
    ).done( =>
      Visio.manager.includeExternalStrategyData true

      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      Visio.manager.set 'setup', true
      NProgress.done()
    )



