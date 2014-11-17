class Visio.Legends.Absy extends Visio.Legends.Base

  type: Visio.FigureTypes.ABSY

  drawFigures: (svgEl) ->
    @drawCircleLegend svgEl

    concentricY = 120
    concentricR = 22
    circleLineLength = 40

    concentricG = d3.select(svgEl)
      .attr('width', 300)
      .attr('height', 300)
      .append('svg')
      .attr('width', 300)
      .attr('height', 300)
      .append('g')
      .attr('transform', "translate(2, #{concentricY})")
    circles = concentricG.selectAll('.concentric-circle').data([1, 2, 3, 4])
    circles.enter().append('circle')
    circles.attr('class', 'concentric-circle')
      .attr('cx', concentricR)
      .attr('cy', (d) -> (2 * concentricR) - concentricR / d)
      .attr('r', (d) -> concentricR / d)

    circleLine = concentricG.selectAll('.concentric-legend-line').data([0])
    circleLine.enter().append('line')
    circleLine.attr('class', (d) -> 'concentric-legend-line')
      .attr('x1', (concentricR) + 2)
      .attr('x2', (concentricR) + 2 + circleLineLength)
      .attr('y1', 2 * concentricR)
      .attr('y2', 2 * concentricR)
    circleLine.exit().remove()

    circleLabel = concentricG.selectAll('.concentric-legend-label').data(['Size is # of Indicators'])
    circleLabel.enter().append('text')
    circleLabel.attr('class', (d) -> 'concentric-legend-label')
      .attr('x', (concentricR) + 2 + circleLineLength)
      .attr('y', 2 * concentricR)
      .attr('dy', '.33em')
      .text(String)
    circleLabel.exit().remove()


  circleData: =>
    ['Within Strategy', 'Outside Strategy']
