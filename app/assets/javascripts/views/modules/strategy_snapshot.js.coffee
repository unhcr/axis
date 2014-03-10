class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  @include Visio.Mixins.Exportable

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    if options.isPdf
      @template = HAML['pdf/strategy_snapshot']
      @criticalityConfig.width = 60
      @criticalityConfig.height = 60


    super options

    unless options.isPdf
      @actionSlider = new Visio.Views.ActionSliderView
        collection: Visio.manager.strategy()[Visio.Parameters.STRATEGY_OBJECTIVES.plural]()

    @countrySlider = new Visio.Views.CountrySliderView
      filters: @filters
      collection: @collection
      isPdf: options.isPdf

    @parameter = @collection

  title: 'Overview'

  type: Visio.ViewTypes.OVERVIEW

  viewLocation: 'Views'

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'
    'click .grid-view': 'onGridView'
    'click .export': 'onExport'

  render: (isRerender) ->
    super isRerender
    if !isRerender
      @$el.find('.header-buttons').append (new Visio.Views.FilterBy({ figure: @ })).render().el
      @$el.find('.target-countries').html @countrySlider?.render().el
      @$el.find('.actions').html @actionSlider?.render().el
      @countrySlider?.delegateEvents()
      @actionSlider?.delegateEvents()

    if @countrySlider?
      @countrySlider.drawFigures()
    if @actionSlider?
      @actionSlider.drawFigures()


    @

  onGridView: ->
    @countrySlider.$el.find('.slider').toggleClass 'grid'
    @countrySlider.reset()
