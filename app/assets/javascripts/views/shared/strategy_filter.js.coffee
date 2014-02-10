class Visio.Views.StrategyFilterView extends Backbone.View

  className: 'strategy-filter map-filter'

  template: HAML['shared/strategy_filter']

  events:
    'change .visio-checkbox input': 'onChangeCheck'

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

        Visio.FigureInstances.map.filterTooltips(Visio.manager.selectedStrategyPlanIds())
      )
    else
      delete Visio.manager.get('selected_strategies')[$target.val()]
      Visio.FigureInstances.map.filterTooltips(Visio.manager.selectedStrategyPlanIds())
