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
      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      @navigation = new Visio.Views.NavigationView el: $('#navigation')
      @navigation.render()


      $('#navigation').removeClass('gone')

      $collapsable = $('.collapsable-content')
      $collapsable.attr 'data-0', "max-height:#{$('.collapsable-content').height()}px"
      $collapsable.attr "data-#{$('.collapsable-content').height()}", "max-height:0px"
      Visio.manager.set('setup', true)
      NProgress.done()
    )

