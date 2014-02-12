class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    Visio.Views.Dashboard.prototype.initialize.call @, options
    @countrySlider = new Visio.Views.CountrySliderView({ collection: @collection })
    @actionSlider = new Visio.Views.ActionSliderView
      collection: Visio.manager.strategy()[Visio.Parameters.STRATEGY_OBJECTIVES.plural]()

    @parameter = @collection

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'

  render: (isRerender) ->
    Visio.Views.Dashboard.prototype.render.call @, isRerender
    @$el.find('.target-countries').html @countrySlider.render().el
    @$el.find('.actions').html @actionSlider.render().el


    @
