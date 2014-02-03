class Visio.Views.IsyShowView extends Visio.Views.AccordionShowView

  template: HAML['modules/isy_show']

  className: 'isy-container accordion-show-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'mouseenter .box': 'onMouseenterBox'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'
    'change .goal-type': 'onGoalTypeChange'
    'change .is-performance': 'onIsPerformanceChange'

  initialize: (options) ->
    @config =
      margin:
        top: 10
        bottom: 10
        left: 10
        right: 10
      width: 800
      height: 300
      figureId: @isyFigureId()

    @sparkConfig =
      margin:
        left: 0
        right: 10
        top: 20
        bottom: 0
      width: 100

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @isyFigureId() })

      # Initialize the indicator bar graph
      @config.selection = d3.select(@el).select('.indicator-bar-graph')
      Visio.FigureInstances[@isyFigureId()] = Visio.Figures.isy @config

      # Initialize the side spark bar graph
      @sparkConfig.selection = d3.select(@el).select('.spark-bar-graph')
      Visio.FigureInstances[@sparkFigureId()] = Visio.Figures.sparkBarGraph(@sparkConfig)

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

    Visio.FigureInstances[@sparkFigureId()].data situationAnalysis
    Visio.FigureInstances[@sparkFigureId()]()

    @drawFigures()

    @toolbarHeight or= $('.toolbar').height()

    @

  onGoalTypeChange: (e) ->
    $target = $(e.currentTarget)
    if $target.is ':checked'
      Visio.FigureInstances[@isyFigureId()].goalType(Visio.Algorithms.GOAL_TYPES.target)()
    else
      Visio.FigureInstances[@isyFigureId()].goalType(Visio.Algorithms.GOAL_TYPES.standard)()

  onIsPerformanceChange: (e) ->
    $target = $(e.currentTarget)
    Visio.FigureInstances[@isyFigureId()].isPerformance($target.is(':checked'))()

  drawFigures: ->
    Visio.FigureInstances[@isyFigureId()].data @model.selectedIndicatorData().models
    Visio.FigureInstances[@isyFigureId()]()

  changeIsPerformance: (isPerformance) ->
    Visio.FigureInstances[@isyFigureId()].isPerformance isPerformance
    Visio.FigureInstances[@isyFigureId()]()

  onMouseenterBox: (e) ->
    d = d3.select(e.currentTarget).datum()

    containerTypes = ['ppg', 'goal', 'indicator']
    _.each containerTypes, (type) =>
      @$el.find(".js-#{type}-container").text Visio.manager.get("#{type}s").get(d.get("#{type}_id"))

  isyFigureId: =>
    "isy-#{@model.id}"

  sparkFigureId: =>
    "spark-#{@model.id}"

  removeInstances: =>
    delete Visio.FigureInstances[@isyFigureId()]
    delete Visio.FigureInstances[@sparkFigureId()]