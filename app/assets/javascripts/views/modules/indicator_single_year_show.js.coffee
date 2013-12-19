class Visio.Views.IndicatorSingleYearShowView extends Backbone.View

  template: JST['modules/indicator_single_year_show']

  initialize: (options) ->
    @config = {
      margin:
        left: 10
        right: 10
        top: 10
        bottom: 10
      width: 400
      height: 300
    }

  render: () ->
    @$el.html @template({ parameter: @model })
    @config.selection = d3.select(@el).select('.indicator-bar-graph')
    @indicatorBarGraph = Visio.Graphs.indicatorBarGraph(@config)

    @

  graph: () ->
    @indicatorBarGraph.data @model.selectedIndicatorData()
    @indicatorBarGraph()

  events:
    'click .js-parameter': 'onClickParameter'

  onClickParameter: (e) ->
    $container = @$el.find '.js-data'
    $('.js-data').not($container).addClass 'zero-max-height'
    $container.toggleClass 'zero-max-height'

    @graph() unless $container.hasClass 'zero-max-height'
