class Visio.Views.IsyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/isy_show']

  className: 'isy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    @config =
      margin:
        top: 10
        bottom: 10
        left: 10
        right: 10
      width: 800
      height: 300

    @isyFigure = new Visio.Figures.Isy @config
    @filterBy = new Visio.Views.FilterBy({ figure: @isyFigure, })
    @sortBy = new Visio.Views.Dropdown
      title: 'Sort By'
      data: [
          { label: 'Baseline to MYR', value: Visio.ProgressTypes.BASELINE_MYR.value, checked: true },
          { label: 'Baseline to YER', value: Visio.ProgressTypes.BASELINE_YER.value },
          { label: 'MYR to YER', value: Visio.ProgressTypes.MYR_YER.value },
        ]
      callback: (value, data) =>
        progress = _.findWhere _.values(Visio.ProgressTypes), { value: value }
        @isyFigure.sortAttribute = progress
        @isyFigure.render()

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @isyFigure.figureId() })

      @$el.find('.indicator-bar-graph').html @isyFigure.el
      @$el.find('.header-buttons').append @filterBy.render().el
      @$el.find('.header-buttons').append @sortBy.render().el

      @$el.find('.slider').slider
        animate: true
        slide: @onSlide
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

    @

  onSlide: (e, ui) ->
    console.log ui.value
  drawFigures: ->
    @isyFigure.collectionFn @model.selectedIndicatorData()

    @isyFigure.render()
    @$el.find('.slider').slider 'option', 'max', @isyFigure.filtered(@isyFigure.collection).length

  removeInstances: =>
