class Visio.Views.SnapshotView extends Visio.Views.Dashboard

  @include Visio.Mixins.Exportable

  template: HAML['modules/strategy_snapshot']

  initialize: (options = {}) ->
    @isPdf = options.isPdf
    barConfig =
      margin:
        top: 2
        bottom: 0
        left: 2
        right: 10
      orientation: 'bottom'
      width: 82
      height: 380
      hasLabels: true

    axisHeight = 380
    if options.isPdf
      @template = HAML['pdf/strategy_snapshot']
      barConfig.height = 340
      axisHeight = 340

    @axis = new Visio.Figures.Axis
      margin:
        top: 10
        bottom: 10
        left: 44
      width: 50
      height: axisHeight

    options.barConfig = barConfig
    super options

    @collection or= Visio.manager.selected Visio.manager.get('aggregation_type')
    @parameter = null

    @parameterSlider = new Visio.Views.ParameterSliderView
      filters: @filters
      collection: @collection
      isPdf: @isPdf

  title: 'Overview'

  type: Visio.FigureTypes.OVERVIEW

  viewLocation: 'Views'

  events:
    'change .ui-blank-radio > input': 'onChangeOperation'
    'click .js-show-all': 'onClickShowAll'
    'click .grid-view': 'onGridView'
    'click .export': 'onExport'

  render:  ->
    @collection = Visio.manager.selected Visio.manager.get('aggregation_type') unless @isPdf

    # If we've changed parameter type we need to rerender
    parameterTypeChanged = !@parameter? or (@parameter.name != @collection.name)

    # If the length of the collection length has changed we need to rerender
    collectionLengthChanged = !@parameter? or (@parameter.length != @collection.length)

    @parameter = @collection
    @parameterSlider?.collection = @collection

    super (!parameterTypeChanged or !collectionLengthChanged)

    if parameterTypeChanged
      @$el.find('.header-buttons').append (new Visio.Views.FilterBy({ figure: @ })).render().el
      @$el.find('.bar-axis').html @axis?.render().el

    if parameterTypeChanged or collectionLengthChanged
      @$el.find('.target-parameters').html @parameterSlider?.render().el
      @parameterSlider?.delegateEvents()
      @parameterSlider?.position = 0

    if @parameterSlider?
      @parameterSlider.drawFigures()

    $exp = @$el.find('.export')
    $exp.attr 'original-title', HAML['tooltips/info']({ text: 'Export' }) if $exp
    $exp.tipsy
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30

    @$el.find('.interactive-legend').tipsy
      className: 'tipsy-black'
      trigger: 'hover'
      offset: 30


    @

  onGridView: ->
    @parameterSlider.$el.find('.slider').toggleClass 'grid'
    @parameterSlider.reset()
