class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    Visio.Views.Dashboard.prototype.initialize.call @, options
    @slider = new Visio.Views.CountrySliderView({ collection: @collection })
    @parameter = @collection

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'

  render: (isRerender) ->
    Visio.Views.Dashboard.prototype.render.call @, isRerender
    @$el.find('.target-countries').html @slider.render().el
    @
