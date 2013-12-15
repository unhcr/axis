class Visio.Views.PriorityCountryFilterView extends Backbone.View

  className: 'priority-country-filter map-filter'

  template: JST['shared/priority_country_filter']

  events:
    'change .visio-check input': 'onChangeCheck'

  initialize: (options) ->

    @render()

  render: () ->
    @$el.html @template(
      strategies: Visio.manager.get('strategies').toJSON()
    )
    @

  onChangeCheck: (e) ->
    $target = $(e.currentTarget)
    if $target.is(':checked')
      options =
        strategy_id: $target.val()
      Visio.manager.get('indicator_data').fetchSynced(options).done(() =>
        Visio.manager.get('selected_strategies')[$target.val()] = true

        @filter _.keys(Visio.manager.get('selected_strategies'))
      )
    else
      delete Visio.manager.get('selected_strategies')[$target.val()]
      @filter _.keys(Visio.manager.get('selected_strategies'))


  filter: (strategy_ids) ->
    if strategy_ids.length == 0
      Visio.router.map.filterTooltips()
      return

    strategies = Visio.manager.strategies(strategy_ids)

    plan_ids = strategies.map (strategy) -> _.keys(strategy.get('plans_ids'))
    plan_ids = _.intersection.apply(null, plan_ids)

    Visio.router.map.filterTooltips(plan_ids)
