class Visio.Views.IsyShowView extends Visio.Views.AccordionShowView

  @include Visio.Mixins.Slidify

  template: HAML['modules/isy_show']

  className: 'isy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onParameterTransitionEnd'
    'MSTransitionEnd': 'onParameterTransitionEnd'
    'webkitTransitionEnd': 'onParameterTransitionEnd'
    'oTransitionEnd': 'onParameterTransitionEnd'

  initialize: (options) ->
    config =
      margin:
        top: 85
        bottom: 100
        left: 115
        right: 30
      width: @figureWidth true
      height: 475

    @figure = new Visio.Figures.Isy config
    @narratify @figure

    @filterBy = new Visio.Views.FilterBy({ figure: @figure, })
    @queryBy = new Visio.Views.QueryBy figure: @figure, placeholder: 'Search for an indicator'
    @sortBy = new Visio.Views.Dropdown
      className: 'sort-by'
      title: 'Sort By'
      data: [
          { label: 'Baseline to MYR', value: Visio.ProgressTypes.BASELINE_MYR.value, checked: true },
          { label: 'Baseline to YER', value: Visio.ProgressTypes.BASELINE_YER.value },
          { label: 'MYR to YER', value: Visio.ProgressTypes.MYR_YER.value },
          { label: '# of Inconsistencies', value: 'inconsistent' }
        ]
      callback: (value, data) =>
        if value == 'inconsistent'
          @figure.sortAttribute = value
        else
          progress = _.findWhere _.values(Visio.ProgressTypes), { value: value }
          @figure.sortAttribute = progress
        @figure.render()

    @initSlider @figure

    $.subscribe "drawFigures.#{@figure.cid}.figure", @drawFigures

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @figure.figureId() })

      @$el.find('.indicator-bar-graph').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el
      @$el.find('.header-buttons').append @queryBy.render().el

      @renderSlider()

    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    # Remove any previous category class from pin
    @$el.find('.pin').removeClass () ->
      classes = _.values(Visio.Algorithms.ALGO_RESULTS).map (result) -> 'pin-' + result
      classes.join ' '

    # Add recomputed category class
    @$el.find('.pin').addClass "pin-#{category}"

    if @model.selectedIndicatorData().length == 0
      @$el.addClass 'disabled'
      @shrink()
    else
      @$el.removeClass 'disabled'

    @drawFigures() if @isOpen()
    @

  drawFigures: =>
    # rerender filter by
    @filterBy.render true

    @figure.collectionFn @model.selectedIndicatorData()
    max = @figure.getMax()

    @figure.render()

    @setSliderMax max

    # No reason to show slider if there is nothing to slide
    if max < @figure.maxIndicators
      @hideSlider()
    else
      @showSlider()

  removeInstances: =>
    $.unsubscribe "drawFigures.#{@figure.cid}.figure"
    $.unsubscribe "hover.#{@figure.cid}.figure"
    @figure.tooltip?.close()
    @figure?.close()

  close: =>
    super
    @removeInstances()
