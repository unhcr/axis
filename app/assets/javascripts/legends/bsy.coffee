class Visio.Legends.Bsy extends Visio.Legends.Base

  initialize: ->
    super
    @breakdownBy = 'budget_type'

    $.subscribe 'legend.breakdown', @onChangeBreakdown

  type: Visio.FigureTypes.BSY

  drawFigures: ->
    # Bar legend
    #
    height = 75
    barWidth = 10
    padding = 1
    barCircleRadius = 2
    barLineEnd = 58

    svg = d3.select(@$el.find('.bsy-bar-legend-container')[0])
    svg.attr('width', Visio.Constants.LEGEND_WIDTH)
    svg.attr('height', height)


    data = [
      { scenario: Visio.Scenarios.OL, amountType: Visio.Syncables.BUDGETS }
      { scenario: Visio.Scenarios.AOL, amountType: Visio.Syncables.BUDGETS }
      { scenario: Visio.Scenarios.OL, amountType: Visio.Syncables.EXPENDITURES }
    ]


    bars = svg.selectAll('.bsy-bar-legend').data(data)
    bars.enter().append('rect')
    bars.attr('class', (d) ->
      classList = ['bsy-bar-legend']
      classList.push Visio.Utils.stringToCssClass d.scenario
      classList.push Visio.Utils.stringToCssClass d.amountType.plural
      classList.join ' '
      )
      .attr('x', (d, i) -> (barWidth + padding) * i)
      .attr('y', 0)
      .attr('height', height)
      .attr('width', barWidth)

    bars.exit().remove()

    barCircles = svg.selectAll('.bsy-bar-legend-circle').data(data)
    barCircles.enter().append('circle')
    barCircles.attr('class', 'bsy-bar-legend-circle')
      .attr('cx', (d, i) -> ((barWidth + padding) * i) + barWidth / 2)
      .attr('cy', (d, i) -> (height * (i / data.length)) + ((1 / 6) * height))
      .attr('r', barCircleRadius)

    barCircles.exit().remove()

    barLines = svg.selectAll('.bsy-bar-legend-line').data(data)
    barLines.enter().append('line')
    barLines.attr('class', 'bsy-bar-legend-line')
      .attr('x1', (d, i) -> ((barWidth + padding) * i) + (barWidth / 2) + barCircleRadius)
      .attr('x2', barLineEnd)
      .attr('y1', (d, i) -> (height * (i / data.length)) + ((1 / 6) * height))
      .attr('y2', (d, i) -> (height * (i / data.length)) + ((1 / 6) * height))

    barLines.exit().remove()

    barLabels = svg.selectAll('.bsy-bar-legend-label').data(data)
    barLabels.enter().append('text')
    barLabels.attr('class', 'bsy-bar-legend-label')
      .attr('x', barLineEnd)
      .attr('y', (d, i) -> (height * (i / data.length)) + ((1 / 6) * height))
      .attr('dy', '.33em')
      .text((d) ->
        prefix = ''
        if d.amountType  == Visio.Syncables.BUDGETS
          prefix = if d.scenario == Visio.Scenarios.AOL then 'AOL ' else 'OL '

        "#{prefix}#{d.amountType.human}"


      )

    barLabels.exit().remove()

    # Circle legend
    #
    #
    circleHeight  = 200
    circlePadding = 6
    circleLineLength = 40
    r             = 7

    circleSvg = d3.select(@$el.find('.bsy-color-legend-container')[0])
    circleSvg.attr('width', Visio.Constants.LEGEND_WIDTH)
    circleSvg.attr('height', circleHeight)

    circleData = @circleData @breakdownBy
    circles = circleSvg.selectAll('.bsy-color-legend').data(circleData, (d, i) -> i)
    circles.enter().append('circle')
    circles.attr('class', (d) ->
      classList = ['bsy-color-legend']
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

    circleLines = circleSvg.selectAll('.bsy-color-legend-line').data(circleData)
    circleLines.enter().append('line')
    circleLines.attr('class', (d) -> 'bsy-color-legend-line')
      .attr('x1', (2 * r) + 2)
      .attr('x2', (2 * r) + 2 + circleLineLength)
      .attr('y1', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
      .attr('y2', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
    circleLines.exit().remove()

    circleLabels = circleSvg.selectAll('.bsy-color-legend-label').data(circleData)
    circleLabels.enter().append('text')
    circleLabels.attr('class', (d) -> 'bsy-color-legend-label')
      .attr('x', (2 * r) + 2 + circleLineLength)
      .attr('y', (d, i) -> ((2 * r + circlePadding) * i) + r + 2)
      .attr('dy', '.33em')
      .text((d) -> Visio.Budgets[d] or Visio.Pillars[d])
    circleLabels.exit().remove()

  circleData: (breakdown) ->

    switch breakdown
      when 'budget_type'
        _.keys Visio.Budgets
      when 'pillar'
        _.keys Visio.Pillars

  onChangeBreakdown: (e, breakdownBy) =>
    @breakdownBy = breakdownBy
    @drawFigures()

  close: ->
    $.unsubscribe "legend.breakdown"
    @unbind()
    @remove()
