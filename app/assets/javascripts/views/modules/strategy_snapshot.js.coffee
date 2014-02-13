class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  @include Visio.Mixins.Exportable

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    super options
    @countrySlider = new Visio.Views.CountrySliderView({ collection: @collection })
    @actionSlider = new Visio.Views.ActionSliderView
      collection: Visio.manager.strategy()[Visio.Parameters.STRATEGY_OBJECTIVES.plural]()

    @parameter = @collection

  title: 'Overview'

  type: Visio.ViewTypes.OVERVIEW

  viewLocation: 'Views'

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'
    'click .grid-view': 'onGridView'
    'click a.export': 'onExport'

  render: (isRerender) ->
    super isRerender
    @$el.find('.target-countries').html @countrySlider.render().el
    @$el.find('.actions').html @actionSlider.render().el


    @

  onGridView: ->
    @countrySlider.$el.find('.slider').toggleClass 'grid'
    @countrySlider.reset()
