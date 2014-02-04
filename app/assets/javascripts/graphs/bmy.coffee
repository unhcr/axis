Visio.Figures.bmy = (config) ->
  margin = config.margin

  figureId = config.figureId

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection || d3.select($('<div></div>')[0])

  tooltip = null
  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)
    .attr('class', 'svg-bmy-figure')
    .on('mouseleave', () ->
      tooltip.close() if tooltip?
      tooltip = null
      d3.select(@).selectAll('.point').transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    )

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  x = d3.scale.ordinal()
    .rangePoints([0, width])
    .domain(Visio.manager.get('yearList'))

  y = d3.scale.linear()
    .range([height, 0])

  lineFn = d3.svg.line()
    .x((d) -> x(d.year))
    .y((d) -> y(d.amount))

  showTotal = if config.showTotal? then config.showTotal else true

  domain = null

  voronoiFn = d3.geom.voronoi()
    .x((d) -> x(d.year))
    .y((d) -> y(d.amount))
    .clipExtent([[-margin.left, -margin.top], [width + margin.right, height + margin.bottom]])

  filtered = []
  isExport = if config.isExport? then config.isExport else false

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')
    .ticks(6)
    .innerTickSize(14)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .ticks(5)
    .innerTickSize(14)
    .tickPadding(20)

  data = config.data || []

  g.append('g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(0,0)')
    .append("text")

  g.append('g')
    .attr('class', 'x axis')
    .attr('transform', "translate(0,#{height})")
    .append("text")

  render = ->

    filtered = render.filtered(data)
    y.domain [0, d3.max(_.flatten(filtered), (d) -> d.amount)]

    lines = g.selectAll('.budget-line').data(filtered)
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('d', lineFn)
      .attr('class', (d) -> ['budget-line', "budget-line-#{d.budgetType}", d.budgetType].join(' '))

    # For selecting line segments

    voronoi = g.selectAll('.voronoi').data(voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', polygon)
      .on('mouseenter', (d) ->
        pointData = _.chain(filtered).flatten().where({ year: d.point.year }).value()
        points = g.selectAll('.point').data(pointData)
        points.enter().append 'circle'
        points
          .attr('r', 5)
          .attr('class', (d) -> ['point', d.budgetType].join(' '))
        points.transition().duration(Visio.Durations.FAST).ease('linear')
          .attr('cx', (d) -> x(d.year))
          .attr('cy', (d) -> y(d.amount))
        points.exit().remove()


        if tooltip?
          tooltip.year = d.point.year
          tooltip.collection = new Backbone.Collection(pointData)
          tooltip.render(true)
        else
          tooltip = new Visio.Views.BmyTooltip
            figure: render
            year: d.point.year
            collection: new Backbone.Collection(pointData)

      )

    if isExport
      voronoi.on('click', (d, i) ->
        # ASSUMES DETERMINISTIC FLATTEN FUNCTION
        count = 0
        lineIndex = null
        _.each filtered, (lineArray, lineArrayIndex) ->
          _.each lineArray, (lineDatum) ->
            lineIndex = lineArrayIndex if count == i
            count += 1

        $.publish "select.#{figureId}", [d.point, lineIndex])

    voronoi.exit().remove()

    g.select('.x.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(xAxis)

    g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(yAxis)
      .attr('transform', 'translate(-20,0)')


  render.data = (_data) ->
    return data unless arguments.length
    data = _data
    render

  render.filtered = (_data) ->
    _.chain(_data).reduce(reduceFn, []).value()

  polygon = (d) ->
    return "M0 0" unless d.length
    "M" + d.join("L") + "Z"

  render.el = () ->
    return selection.node()

  render.config = ->
    return {
      margin: margin
      width: config.width
      height: config.height
      data: data
      showTotal: showTotal
    }

  render.x = (_x) ->
    return x unless arguments.length
    x = _x
    render

  render.showTotal = (_showTotal) ->
    return showTotal unless arguments.length
    showTotal = _showTotal
    render

  render.height = (_height) ->
    return height unless arguments.length
    height = _height
    render

  render.isExport = (_isExport) ->
    return isExport unless arguments.length
    isExport = _isExport
    render

  render.figureId = ->
    return figureId

  render.margin = (_margin) ->
    return margin unless arguments.length
    margin = _margin
    render

  select = (e, d, i) ->
    line = g.select(".budget-line-#{d.budgetType}")
    isActive = line.classed 'active'
    line.classed 'active', not isActive

  render.exportId = ->
    figureId + '_export'

  render.unsubscribe = ->
    $.unsubscribe "select.#{figureId}.figure"

  reduceFn = (memo, budget) ->
    unless budget.get('year')
      console.warn 'No year for budget: ' + budget.id
      return memo

    # Add budget type array
    lineData = _.find memo, (array) -> array.budgetType == budget.get 'budget_type'
    unless lineData
      lineData = []
      lineData.budgetType = budget.get 'budget_type'
      memo.push lineData

    # Add line datum
    datum = _.findWhere lineData, { year: budget.get 'year' }
    unless datum
      datum = { amount: 0, year: budget.get('year'), budgetType: budget.get('budget_type') }
      lineData.push datum

    datum.amount += budget.get 'amount'

    if showTotal
      # Add 'total' array
      totalData = _.find memo, (array) -> array.budgetType == 'total'
      unless totalData
        totalData = []
        totalData.budgetType = 'total'
        memo.push totalData

      # Add total datum
      total = _.findWhere totalData, { year: budget.get 'year' }
      unless total
        total = { amount: 0, year: budget.get('year'), budgetType: 'total' }
        totalData.push total
      total.amount += budget.get 'amount'

    return memo

  $.subscribe "select.#{figureId}.figure", select
  render
