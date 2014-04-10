class Visio.Views.StrategySnapshotView extends Visio.Views.Dashboard

  @include Visio.Mixins.Exportable

  template: HAML['modules/strategy_snapshot']

  initialize: (options) ->
    @isPdf = options.isPdf
    @barConfig.orientation = 'bottom'
    @barConfig.width = 82
    @barConfig.height = 380
    @barConfig.margin.bottom = 0
    axisHeight = 380
    if options.isPdf
      @template = HAML['pdf/strategy_snapshot']
      @barConfig.height = 340
      @barConfig.hasLabels = true
      axisHeight = 340

    @axis = new Visio.Figures.Axis
      margin:
        top: 10
        bottom: 10
        left: 40
      width: 50
      height: axisHeight

    super options

    @collection or= Visio.manager.selected Visio.manager.get('aggregation_type')
    @parameter = @collection

    unless @isPdf
      @actionSlider = new Visio.Views.ActionSliderView
        collection: Visio.manager.selected Visio.Parameters.STRATEGY_OBJECTIVES.plural
    @parameterSlider = new Visio.Views.ParameterSliderView
      filters: @filters
      collection: @collection
      isPdf: @isPdf

  title: 'Overview'

  type: Visio.ViewTypes.OVERVIEW

  viewLocation: 'Views'

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'
    'click .grid-view': 'onGridView'
    'click .export': 'onExport'

  render: (isRerender) ->
    @collection = Visio.manager.selected Visio.manager.get('aggregation_type') unless @isPdf
    @parameter = @collection
    @parameterSlider?.collection = @collection

    super isRerender

    unless isRerender
      @$el.find('.header-buttons').append (new Visio.Views.FilterBy({ figure: @ })).render().el
      @$el.find('.target-parameters').html @parameterSlider?.render().el
      @$el.find('.actions').html @actionSlider?.render().el
      @$el.find('.bar-axis').html @axis?.render().el
      @parameterSlider?.delegateEvents()
      @actionSlider?.delegateEvents()
      @parameterSlider?.position = 0
      @actionSlider?.position = 0

    if @parameterSlider?
      @parameterSlider.drawFigures()
    if @actionSlider?
      @actionSlider.drawFigures()

    @

  onGridView: ->
    @parameterSlider.$el.find('.slider').toggleClass 'grid'
    @parameterSlider.reset()
