class Visio.Views.IndicatorSingleYearShowView extends Backbone.View

  template: JST['modules/indicator_single_year_show']

  className: 'isy-container'

  events:
    'click': 'onClickParameter'
    'mouseenter .box': 'onMouseenterBox'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  initialize: (options) ->
    @config = {
      margin:
        top: 10
        bottom: 10
        left: 10
        right: 10
      width: 800
      height: 300
    }

    @sparkConfig = {
      margin:
        left: 0
        right: 10
        top: 20
        bottom: 0
      width: 100
    }

  render: (isRerender) ->
    situationAnalysis = @model.selectedSituationAnalysis()

    if !isRerender
      @$el.html @template({ parameter: @model })

      # Initialize the indicator bar graph
      @config.selection = d3.select(@el).select('.indicator-bar-graph')
      @indicatorBarGraph = Visio.Graphs.indicatorBarGraph(@config)

      # Initialize the side spark bar graph
      @sparkConfig.selection = d3.select(@el).select('.spark-bar-graph')
      @sparkBarGraph = Visio.Graphs.sparkBarGraph(@sparkConfig)

    category = if situationAnalysis.total == 0 then 'white' else situationAnalysis.category

    # Remove any previous category class from pin
    @$el.find('.pin').removeClass () ->
      classes = _.values(Visio.Algorithms.ALGO_RESULTS).map (result) -> 'pin-' + result
      classes.join ' '

    # Add recomputed category class
    @$el.find('.pin').addClass "pin-#{category}"

    if situationAnalysis.total == 0
      @$el.addClass 'disabled'
      @shrink()
    else
      @$el.removeClass 'disabled'

    @sparkBarGraph.data situationAnalysis
    @sparkBarGraph()

    @graph()

    @toolbarHeight or= $('.toolbar').height()

    @

  graph: ->
    @indicatorBarGraph.data @model.selectedIndicatorData()
    @indicatorBarGraph()

  changeIsPerformance: (isPerformance) ->
    @indicatorBarGraph.isPerformance isPerformance
    @indicatorBarGraph()

  isOpen: =>
    @$el.hasClass 'open'

  expand: =>
    @$el.addClass 'open'

  shrink: =>
    @$el.removeClass 'open'

  onMouseenterBox: (e) ->
    d = d3.select(e.currentTarget).datum()

    containerTypes = ['ppg', 'goal', 'indicator']
    _.each containerTypes, (type) =>
      @$el.find(".js-#{type}-container").text Visio.manager.get("#{type}s").get(d.get("#{type}_id"))

  onTransitionEnd: (e) ->
    if @isOpen()
      $.scrollTo @$el,
        duration: 100
        offset:
          top: -@toolbarHeight
          left: 0


  onClickParameter: (e) ->

    $('.isy-container').not(@$el).removeClass 'open'
    @$el.toggleClass 'open'

    @graph() if @isOpen()

  close: ->
    @unbind()
    @remove()
