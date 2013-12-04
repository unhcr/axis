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
    strategy_id = $(e.currentTarget).val()
    Visio.manager.get('indicator_data').fetchSynced({ strategy_id: strategy_id }).done(() =>
      strategy_ids = @$el.find('.visio-check input:checked').map((i, ele) -> +$(ele).val())
      @filter(strategy_ids)
    )


  filter: (strategy_ids) ->
    if strategy_ids.length == 0
      Visio.router.map.filterTooltips()
      return

    plan_ids = _.intersection.apply(null, Visio.manager.strategies(strategy_ids).pluck('plans_ids'))

    Visio.router.map.filterTooltips(plan_ids)
