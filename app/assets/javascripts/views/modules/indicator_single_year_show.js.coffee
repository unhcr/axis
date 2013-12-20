class Visio.Views.IndicatorSingleYearShowView extends Backbone.View

  template: JST['modules/indicator_single_year_show']

  className: 'isy-container'

  initialize: (options) ->
    @config = {
      margin:
        top: 10
        bottom: 10
      width: 400
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

  render: ->
    @$el.html @template({ parameter: @model })
    @config.selection = d3.select(@el).select('.indicator-bar-graph')
    @indicatorBarGraph = Visio.Graphs.indicatorBarGraph(@config)

    @sparkConfig.selection = d3.select(@el).select('.spark-bar-graph')
    @sparkBarGraph = Visio.Graphs.sparkBarGraph(@sparkConfig)
    @sparkBarGraph.data @model.selectedSituationAnalysis()
    @sparkBarGraph()

    @toolbarHeight or= $('.toolbar').height()

    @

  graph: ->
    @indicatorBarGraph.data @model.selectedIndicatorData()
    @indicatorBarGraph()

  changeProgress: (progress) ->
    @indicatorBarGraph.progress progress
    @indicatorBarGraph()

  changeIsPerformance: (isPerformance) ->
    @indicatorBarGraph.isPerformance isPerformance
    @indicatorBarGraph()

  events:
    'click .js-parameter': 'onClickParameter'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'

  isOpen: =>
    @$el.hasClass 'open'


  onTransitionEnd: (e) ->
    if @isOpen()
      $(document).scrollTop @$el.offset().top - @toolbarHeight

  onClickParameter: (e) ->
    $('.isy-container').not(@$el).removeClass 'open'
    @$el.toggleClass 'open'

    @graph() if @isOpen()
