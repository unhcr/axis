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
      strategies = Visio.manager.strategies(strategy_ids)
      @filter(
        plans_ids: _.flatten(strategies.pluck('plans_ids'))
        ppgs_ids: _.flatten(strategies.pluck('ppgs_ids'))
        goals_ids: _.flatten(strategies.pluck('goals_ids'))
        outputs_ids: _.flatten(strategies.pluck('outputs_ids'))
        problem_objectives_ids: _.flatten(strategies.pluck('problem_objectives_ids'))
        indicators_ids: _.flatten(strategies.pluck('indicators_ids'))
      )
    )


  filter: (strategy_ids) ->

    plan_ids = _.intersection(_.flatten(Visio.manager.get('strategies').map((s) ->
      if _.include(strategy_ids, s.id)
        s.get("#{Visio.Parameters.PLANS}_ids")
      else
        return []
      ), true)
    )

    Visio.router.map.filterTooltips(plan_ids)
