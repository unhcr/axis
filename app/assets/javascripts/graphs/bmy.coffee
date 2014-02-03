Visio.Figures.bmy = (config) ->
  margin = config.margin

  figureId = config.figureId

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection || d3.select($('<div></div>')[0])

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)
    .attr('class', 'svg-bmy-figure')

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  x = d3.scale.ordinal()
    .rangeBands([0, width])
    .domain(Visio.manager.get('yearList'))

  y = d3.scale.linear()
    .range([height, 0])

  lineFn = d3.svg.line()
    .x((d) -> x(d.year))
    .y((d) -> y(d.amount))

  domain = null

  voronoiFn = d3.geom.voronoi()
    .x((d) -> return x(d.year))
    .y((d) -> return y(d.amount))
    .clipExtent([[-margin.left, -margin.top], [width + margin.right, height + margin.bottom]])

  filtered = []
  isExport = config.isExport || false

  #xAxis = d3.svg.axis()
  #  .scale(x)
  #  .orient('bottom')
  #  .tickFormat(d3.format('s'))
  #  .ticks(6)
  #  .innerTickSize(14)

  #yAxis = d3.svg.axis()
  #  .scale(y)
  #  .orient('left')
  #  .ticks(5)
  #  .innerTickSize(14)
  #  .tickPadding(20)

  data = config.data || []

  render = ->

    filtered = render.filtered(data)
    y.domain [0, d3.max(_.flatten(filtered), (d) -> d.amount)]

    lines = g.selectAll('.budget-line').data(filtered)
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('d', lineFn)
      .attr('class', (d) -> ['budget-line', "budget-line-#{d.budgetType}"].join(' '))

    console.log _.flatten(filtered)
    voronoi = g.selectAll('.voronoi').data(voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', polygon)
      .on('click', (d) ->
        $.publish "select.#{figureId}", [d.point])
    voronoi.exit().remove()

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
    }

  select = (e, d) ->
    line = g.select(".budget-line-#{d.budgetType}")
    isActive = line.classed 'active'
    line.classed 'active', not isActive

  render.exportId = ->
    figureId + '_export'

  render.unsubscribe = ->
    $.unsubscribe "select.#{figureId}.figure"

  reduceFn = (memo, budget) ->
    budget.set 'year', Visio.manager.get('yearList')[Math.floor(Math.random() * 4)] unless budget.get('year')?
    lineData = _.find memo, (array) -> array.budgetType == budget.get 'budget_type'
    unless lineData
      lineData = []
      lineData.budgetType = budget.get 'budget_type'
      memo.push lineData

    datum = _.findWhere lineData, { year: budget.get 'year' }
    unless datum
      datum = { amount: 0, year: budget.get('year'), budgetType: budget.get('budget_type') }
      lineData.push datum

    datum.amount += budget.get 'amount'
    return memo

  $.subscribe "select.#{figureId}.figure", select
  render