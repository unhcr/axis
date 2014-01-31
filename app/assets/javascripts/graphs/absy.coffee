Visio.Figures.absy = (config) ->

  margin = config.margin

  figureId = config.figureId

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection || d3.select($('<div></div>')[0])

  duration = 500

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)
    .attr('class', 'svg-absy-figure')

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  x = d3.scale.linear()
    .range([0, width])

  y = d3.scale.linear()
    .domain([0, 1])
    .range([height, 0])

  r = d3.scale.sqrt()
    .domain([0, 1000000])
    .range([0, 20])

  domain = null

  isExport = config.isExport || false

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')
    .tickFormat(d3.format('s'))
    .ticks(6)
    .innerTickSize(14)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .ticks(5)
    .tickFormat((d) -> return if d then d * 100 else '0%')
    .innerTickSize(14)
    .tickPadding(20)

  data = config.data || []

  entered = false

  info = null
  voronoi = d3.geom.voronoi()
    .clipExtent([[0, 0], [width, height]])
    .x((d) -> x(d.selectedAmount()))
    .y((d) -> y(d.selectedAchievement().result))

  g.append('g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(0,0)')
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 0)
      .attr("x", -height)
      .attr("dy", "-.21em")
      .style("text-anchor", "start")
      .text('Acheivement')

  g.append('g')
    .attr('class', 'x axis')
    .attr('transform', "translate(0,#{height})")
    .append("text")
      .attr("x", width + 10)
      .attr("dy", "-.21em")
      .style("text-anchor", "start")
      .text('Budget')

  render = () ->

    filtered = data.filter render.filterFn
    maxAmount = d3.max data, (d) -> d.selectedAmount()

    if !domain || domain[1] < maxAmount || domain[1] > 2 * maxAmount
      domain = [0, maxAmount]
      x.domain(domain)

    # trails = g.selectAll('.trail').data(data, (d) -> d.operation_id || d.id)
    # trails.enter().append('line')
    #   .attr('x1', (d) -> x(d.budget))
    #   .attr('y1', (d) -> y(d.achievement))
    # trails
    #   .attr('class', (d) ->
    #     return ['trail'].join(' '))
    # trails.transition()
    #   .duration(Visio.Durations.FAST)
    #   .attr('x1', (d) -> x(d3.select(@).attr('previous-x2') || d.budget))
    #   .attr('y1', (d) -> y(d3.select(@).attr('previous-y2') || d.achievement))
    #   .attr('x2', (d) -> d3.select(@).attr('previous-x2', d.budget); x(d.budget))
    #   .attr('y2', (d) -> d3.select(@).attr('previous-y2', d.achievement); y(d.achievement))
    # trails.exit().remove()

    bubbles = g.selectAll('.bubble').data(filtered, (d) -> d.refId())
    bubbles.enter().append('circle')
    bubbles
      .attr('class', (d) ->
        return ['bubble', "id-#{d.refId()}"].join(' '))
    bubbles
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('r', (d) ->
        return r(600000))
      .attr('cy', (d) ->
        return y(d.selectedAchievement().result))
      .attr('cx', (d) ->
        return x(d.selectedAmount()))

    bubbles.exit().transition().duration(Visio.Durations.FAST).attr('r', 0).remove()

    path = g.selectAll('.voronoi')
      .data(voronoi(filtered))

    path.enter().append("path")
    path.attr("class", (d, i) -> "voronoi" )
        .attr("d", polygon)
        .on('mouseenter', (d) ->
          entered = true
          info or= new Visio.Views.BubbleInfoView({
            el: $('.info-container .bubble-info')
          })
          # Hack for when we move from one to voronoi to another to which fires enter, enter, out in Chrome
          window.setTimeout(( -> entered = false), 50)
          info.render(d.point)
          info.show()
          g.select(".bubble.id-#{d.point.refId()}").classed 'focus', true
        ).on('mouseout', (d) ->
          info.hide() if info and not entered
          g.select(".bubble.id-#{d.point.refId()}").classed 'focus', false

        ).on('click', (d) ->
          $.publish "select.#{figureId}", [d.point]
        )

    path.exit().remove()

    g.select('.x.axis')
      .transition()
      .delay(duration)
      .duration(duration)
      .call(xAxis)

    g.select('.y.axis')
      .transition()
      .duration(duration)
      .call(yAxis)
      .attr('transform', 'translate(-20,0)')

  select = (e, d) ->
    bubble = g.select(".bubble.id-#{d.refId()}")
    isActive = bubble.classed 'active'
    bubble.classed 'active', not isActive


  polygon = (d) ->
    return "M0 0" unless d.length
    "M" + d.join("L") + "Z"

  render.data = (_data) ->
    return data unless arguments.length
    data = _data
    return render

  render.width = (_width) ->
    return width unless arguments.length
    width = _width
    return render

  render.unsubscribe = ->
    $.unsubscribe "select.#{figureId}.figure"

  render.exportId = ->
    return figureId + '_export'

  render.filterFn = (d) ->
    return d.selectedAmount() && d.selectedAchievement().result

  render.el = () ->
    return selection.node()

  render.sortFn = (a, b) -> 0

  render.config = ->
    return {
      margin: margin
      width: config.width
      height: config.height
      data: data
    }

  $.subscribe "select.#{figureId}.figure", select
  return render

