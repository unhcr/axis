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
      NProgress.start()
      Visio.manager.get('indicator_data').fetchSynced(options).done(() =>
        Visio.manager.get('selected_strategies')[$target.val()] = true

        NProgress.done()
        Visio.manager.trigger 'change:selected_strategies'
      )
    else
      delete Visio.manager.get('selected_strategies')[$target.val()]
      Visio.manager.trigger 'change:selected_strategies'
