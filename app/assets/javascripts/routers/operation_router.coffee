class Visio.Routers.OperationRouter extends Visio.Routers.DashboardRouter

  initialize: (options) ->
    super


  setup: () ->
    # Return empty promise if we've setup already
    return $.Deferred().resolve().promise() if Visio.manager.get('setup')

    @toolbarView = new Visio.Views.ToolbarView({ el: $('.toolbar') })
    options =
      join_ids:
        operation_id: Visio.manager.get('dashboard').id

    dataOptions =
      filter_ids:
        operation_ids: [Visio.manager.get('dashboard').id]

    NProgress.start()
    $.when(Visio.manager.get('ppgs').fetchSynced(options),
           Visio.manager.get('goals').fetchSynced(options),
           Visio.manager.get('outputs').fetchSynced(options),
           Visio.manager.get('strategy_objectives').fetch()
           Visio.manager.get('problem_objectives').fetchSynced(options),
           Visio.manager.get('indicators').fetchSynced(options),
           Visio.manager.get('expenditures').fetchSynced(dataOptions),
           Visio.manager.get('budgets').fetchSynced(dataOptions),
           Visio.manager.get('indicator_data').fetchSynced(dataOptions)
    ).done( =>
      Visio.manager.includeExternalStrategyData true

      # Initialize selected to be strategy
      Visio.manager.resetSelectedDefaults()

      @navigation = new Visio.Views.NavigationView el: $('#navigation')
      @navigation.render()

      $('#navigation').removeClass('gone')

      $collapsable = $('.collapsable-content')
      $collapsable.attr 'data-0', "max-height:#{$('.collapsable-content').height()}px"
      $collapsable.attr "data-#{$('.collapsable-content').height()}", "max-height:0px"
      #skrollr.init(
      #  forceHeight: false
      #)
      Visio.manager.set('setup', true)
      NProgress.done()
    )


