class Visio.Views.IndicatorSingleYearShowView extends Backbone.View

  template: JST['modules/indicator_single_year_show']

  className: 'isy-container'

  events:
    'click .js-parameter': 'onClickParameter'
    'mouseenter .box': 'onMouseenterBox'
    'transitionend': 'onTransitionEnd'
    'MSTransitionEnd': 'onTransitionEnd'
    'webkitTransitionEnd': 'onTransitionEnd'
    'oTransitionEnd': 'onTransitionEnd'
    'change .tabs input': 'onChangeProgress'


  initialize: (options) ->
    @config = {
      margin:
        top: 10
        bottom: 10
        left: 10
        right: 10
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

    @$el.find("#progress-#{@indicatorBarGraph.progress()}-#{@model.id}").prop 'checked', true

    @toolbarHeight or= $('.toolbar').height()

    @

  graph: ->
    @indicatorBarGraph.data @model.selectedIndicatorData()
    @indicatorBarGraph()

  onChangeProgress: (e) ->
    console.log 'change'
    @changeProgress($(e.currentTarget).val())

  changeProgress: (progress) ->
    @indicatorBarGraph.progress progress
    @indicatorBarGraph()

  changeIsPerformance: (isPerformance) ->
    @indicatorBarGraph.isPerformance isPerformance
    @indicatorBarGraph()

  isOpen: =>
    @$el.hasClass 'open'

  onMouseenterBox: (e) ->
    d = d3.select(e.currentTarget).datum()

    containerTypes = ['ppg', 'goal', 'indicator']
    _.each containerTypes, (type) =>
      @$el.find(".js-#{type}-container").text Visio.manager.get("#{type}s").get(d.get("#{type}_id"))

  onTransitionEnd: (e) ->
    if @isOpen()
      $(document).scrollTop @$el.offset().top - @toolbarHeight

  onClickParameter: (e) ->
    $('.isy-container').not(@$el).removeClass 'open'
    @$el.toggleClass 'open'

    @graph() if @isOpen()
