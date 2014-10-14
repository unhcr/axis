class Visio.Legends.Bsy extends Visio.Legends.Base

  initialize: ->
    super

    $.subscribe 'legend.breakdown', @onChangeBreakdown

  type: Visio.FigureTypes.BSY

  drawFigures: (svgEl) ->
    # Bar legend
    #
    height = 75
    barWidth = 10
    padding = 1
    barCircleRadius = 2
    barLineEnd = 58

    d3.select(svgEl).attr('height', 400)
    d3.select(svgEl).attr('width', Visio.Constants.LEGEND_WIDTH)

    svg = d3.select(svgEl).append('svg')
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

    @drawCircleLegend svgEl, { y: height }


  circleData: () =>
    breakdownBy = @figure.filters.get('breakdown_by').active()
    switch breakdownBy
      when 'budget_type'
        _.keys Visio.Budgets
      when 'pillar'
        _.keys Visio.Pillars

  circleText: (d) =>
    Visio.Budgets[d] or Visio.Pillars[d]

  close: ->
    $.unsubscribe "legend.breakdown"
    @unbind()
    @remove()
