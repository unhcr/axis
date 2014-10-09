class Visio.Legends.Base extends Backbone.View

  isPdf: false

  className: 'legend'

  initialize: (options = {}) ->
    @$el.addClass "legend-#{@type.name}"
    @figure = options.figure

    if @isPdf
      @template = HAML["pdf/legends/#{@type.name}"]
    else
      @$el.css 'width', Visio.Constants.LEGEND_WIDTH + 'px'
      @template = HAML["legends/#{@type.name}"]

    throw new Error('No legend template defined') unless @template?

  render: ->
    @$el.html @template { type: @type }

    @drawFigures?(@$el.find('svg')[0])
    @

  drawCircleLegend: (svgEl, config = {}) =>
    # Circle legend
    #
    #
    circleHeight  = 200
    circlePadding = 12
    circleLineLength = 40
    r             = 7

    y = (config.y || 0) + 30

    circleSvg = d3.select(svgEl).append('svg')
    circleSvg.attr('width', Visio.Constants.LEGEND_WIDTH)
    circleSvg.attr('height', circleHeight)
      .attr('y', y)

    circleData = @circleData()
    circles = circleSvg.selectAll('.color-legend').data(circleData, (d, i) -> i)
    circles.enter().append('circle')
    circles.attr('class', (d) ->
      classList = ['color-legend']
      classList.push Visio.Utils.stringToCssClass d
      classList.join ' '
      )
    circles
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('cx', r + 2)
      .attr('cy', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
      .attr('r', r)
    circles
      .exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()

    circleLines = circleSvg.selectAll('.color-legend-line').data(circleData)
    circleLines.enter().append('line')
    circleLines.attr('class', (d) -> 'color-legend-line')
      .attr('x1', (2 * r) + 2)
      .attr('x2', (2 * r) + 2 + circleLineLength)
      .attr('y1', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
      .attr('y2', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
    circleLines.exit().remove()

    circleLabels = circleSvg.selectAll('.color-legend-label').data(circleData)
    circleLabels.enter().append('text')
    circleLabels.attr('class', (d) -> 'color-legend-label')
      .attr('x', (2 * r) + 2 + circleLineLength)
      .attr('y', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
      .attr('dy', '.33em')
      .text(@circleText)
    circleLabels.exit().remove()

  circleData: -> []

  circleText: (d) -> d.toUpperCase()

  close: ->
    @unbind()
    @remove()
