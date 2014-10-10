class Visio.Legends.Isy extends Visio.Legends.Base

  type: Visio.FigureTypes.ISY

  templateElement: HAML['legends/isy_element']

  drawFigures: (svgEl) ->
    $(svgEl).html @templateElement()
    data = [
      Visio.Algorithms.GOAL_TYPES.target,
      Visio.Algorithms.ALGO_RESULTS.inconsistent,
      Visio.Algorithms.REPORTED_VALUES.yer,
      Visio.Algorithms.REPORTED_VALUES.myr,
      Visio.Algorithms.REPORTED_VALUES.baseline,
    ]
    height = 158
    barWidth = 10
    padding = 1
    barCircleRadius = 4
    barLineEnd = 90
    lineOffsetX = 24
    lineOffsetY = 24

    svg = d3.select(svgEl).append('svg')
      .attr('height', height + lineOffsetY + 10)
      .attr('width', Visio.Constants.LEGEND_WIDTH)

    barLines = svg.selectAll('.isy-bar-legend-line').data(data)
    barLines.enter().append('line')
    barLines.attr('class', 'isy-bar-legend-line')
      .attr('x1', lineOffsetX)
      .attr('x2', barLineEnd)
      .attr('y1', (d, i) -> lineOffsetY + (height * (i / (data.length - 1))))
      .attr('y2', (d, i) -> lineOffsetY + (height * (i / (data.length - 1))))

    barLines.exit().remove()

    barText = svg.selectAll('.isy-bar-legend-text').data(data)
    barText.enter().append('text')
    barText.attr('class', 'isy-bar-legend-text')
      .attr('x', barLineEnd + 8)
      .attr('y', (d, i) -> lineOffsetY + (height * (i / (data.length - 1))))
      .attr('dy', '.33em')
      .text((d, i) -> Visio.Utils.humanMetric(d))

    barText.exit().remove()

    barCircle = svg.selectAll('.isy-bar-legend-circle').data(data)
    barCircle.enter().append('circle')
    barCircle.attr('class', (d) -> d + ' isy-bar-legend-circle')
      .attr('cx', barLineEnd)
      .attr('cy', (d, i) -> lineOffsetY + (height * (i / (data.length - 1))))
      .attr('r', barCircleRadius)

    barCircle.exit().remove()



    svgEl
