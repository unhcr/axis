class Visio.Routers.OverviewRouter extends Backbone.Router

  initialize: (options) ->
    @navigation = new Visio.Views.NavigationView({
      el: $('#navigation')
    })
    @setup().done(() =>

      @navigation.render()

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
           Visio.manager.get('indicators').fetchSynced(options))


  routes:
    '*default': 'index'

  index: () ->
    console.log 'index'
