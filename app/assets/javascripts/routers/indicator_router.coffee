class Visio.Routers.IndicatorRouter extends Visio.Routers.DashboardRouter

  initialize: (options) ->
    super


  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    options =
      join_ids:
        indicator_id: Visio.manager.get('indicator').id

    dataOptions =
      filter_ids:
        indicator_ids: [Visio.manager.get('indicator').id]

    if Visio.manager.get('indicator').get 'is_performance'
      dataOptionsExpBudget =
        filter_ids:
          output_ids: [Visio.manager.get('dashboard').id]
    else
      dataOptionsExpBudget =
        filter_ids:
          problem_objective_ids: [Visio.manager.get('dashboard').id]

    Visio.manager.get('indicators').reset [Visio.manager.get('indicator')]

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetchSynced(options),
           Visio.manager.get('goals').fetchSynced(options),
           Visio.manager.get('outputs').fetchSynced(options),
           Visio.manager.get('strategy_objectives').fetch({ data: { global_only: true } })
           Visio.manager.get('problem_objectives').fetchSynced(options),
           Visio.manager.get('operations').fetchSynced(options),
           Visio.manager.get('expenditures').fetchSynced(dataOptionsExpBudget),
           Visio.manager.get('budgets').fetchSynced(dataOptionsExpBudget),
           Visio.manager.get('indicator_data').fetchSynced(dataOptions)
    ).done( =>
      Visio.manager.includeExternalStrategyData true

      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      Visio.manager.set 'setup', true
      NProgress.done()
    )



