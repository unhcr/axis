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

    @sparkConfig =
      margin:
        left: 0
        right: 10
        top: 20
        bottom: 0
      width: 100

    @isyFigure = new Visio.Figures.Isy @config
    @sparkFigure = new Visio.Figures.Spark @sparkConfig

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model, figureId: @isyFigure.figureId() })

      @$el.find('.indicator-bar-graph').html @isyFigure.el
      @$el.find('.spark-bar-graph').html @sparkFigure.el

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

    @sparkFigure.dataFn [@model]
    @sparkFigure.render()

    @drawFigures()

    @

  onGoalTypeChange: (e) ->
    $target = $(e.currentTarget)
    if $target.is ':checked'
      @isyFigure.goalTypeFn(Visio.Algorithms.GOAL_TYPES.target).render()
    else
      @isyFigure.goalTypeFn(Visio.Algorithms.GOAL_TYPES.standard).render()

  onIsPerformanceChange: (e) ->
    $target = $(e.currentTarget)
    @isyFigure.isPerformanceFn($target.is(':checked')).render()

  drawFigures: ->
    @isyFigure.dataFn @model.selectedIndicatorData().models
    @isyFigure.render()

  onMouseenterBox: (e) ->
    d = d3.select(e.currentTarget).datum()

    containerTypes = ['ppg', 'goal', 'indicator']
    _.each containerTypes, (type) =>
      @$el.find(".js-#{type}-container").text Visio.manager.get("#{type}s").get(d.get("#{type}_id"))


  removeInstances: =>
