class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  @include Visio.Mixins.Exportable

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    if options.isPdf
      @template = HAML['pdf/strategy_snapshot']
      @criticalityConfig.width = 60
      @criticalityConfig.height = 60

    else
      @actionSlider = new Visio.Views.ActionSliderView
        collection: Visio.manager.strategy()[Visio.Parameters.STRATEGY_OBJECTIVES.plural]()

    @countrySlider = new Visio.Views.CountrySliderView({ collection: @collection, isPdf: options.isPdf })
    super options


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
    @$el.find('.target-countries').html @countrySlider.render().el if @countrySlider?
    @$el.find('.actions').html @actionSlider.render().el if @actionSlider?


    @

  onGridView: ->
    @countrySlider.$el.find('.slider').toggleClass 'grid'
    @countrySlider.reset()
