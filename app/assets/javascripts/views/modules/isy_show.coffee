class Visio.Views.IsyShowView extends Visio.Views.AccordionShowView

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

    $.subscribe "hover.#{@figure.cid}.figure", (e, idxOrDatum) =>
      if idxOrDatum instanceof Visio.Models.IndicatorDatum
        value = @figure.findBoxByDatum(idxOrDatum).idx
      else
        value = idxOrDatum

      @$el.find('.slider').slider 'value', value
      @$el.find('.slider .ui-slider-handle').attr 'data-value', value + 1

    $.subscribe "drawFigures.#{@figure.cid}.figure", @drawFigures

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @figure.figureId() })

      @$el.find('.indicator-bar-graph').html @figure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el
      @$el.find('.header-buttons').append @queryBy.render().el

      @$el.find('.slider').slider
        animate: true
        slide: @onSlide
        stop: @onStop
        min: 0

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

  onStop: (e, ui) =>
    $.publish "mouseout.#{@figure.cid}.figure", ui.value

  onSlide: (e, ui) =>
    $.publish "hover.#{@figure.cid}.figure", ui.value
    @$el.find('.slider .ui-slider-handle').attr 'data-value', ui.value + 1

  drawFigures: =>
    # rerender filter by
    @filterBy.render true

    @figure.collectionFn @model.selectedIndicatorData()
    max = @figure.filtered(@figure.collection).length

    @figure.render()

    $slider = @$el.find('.slider')
    $slider.slider 'option', 'max', max - 1
    $slider.attr 'data-max', max

    # No reason to show slider if there is nothing to slide
    if max < @figure.maxIndicators
      $slider.addClass 'gone'
    else
      $slider.removeClass 'gone'

  removeInstances: =>
    $.unsubscribe "drawFigures.#{@figure.cid}.figure"
    $.unsubscribe "hover.#{@figure.cid}.figure"
    @figure.tooltip?.close()
    @figure?.close()

  close: =>
    super
    @removeInstances()
