Visio.Graphs.indicatorBarGraph = (config) ->
  margin = config.margin

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection

  duration = 500

  isPerformance = true

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  barWidth = 10

  x = d3.scale.linear()
    .domain([0, 30])
    .range([0, width])

  y = d3.scale.linear()
    .range([height, 0])

  progress =
    start: Visio.Algorithms.REPORTED_VALUES.baseline
    end: Visio.Algorithms.REPORTED_VALUES.myr

  goalType = Visio.Algorithms.GOAL_TYPES.target

  data = []


  render = () ->


    boxes = g.selectAll('g.box').data(data.where({ is_performance: isPerformance }))
    boxes.enter().append('g')
    boxes.attr('class', 'box')
      .sort(sort)
      .transition()
      .duration(duration)
      .attr('transform', (d, i) ->
        'translate(' + x(i) + ', 0)'
      )
      .each((d, i) ->
        bar = d3.select @

        y.domain [0, +d.get(goalType)]

        reversed = d.get(progress.start) > d.get(progress.end)
        barHeight = Math.abs(d.get(progress.start) - d.get(progress.end))
        box = bar.selectAll('.box').data([d])
        box.enter().append('rect')
        box.attr('class', (d) ->
          classes = ['box']
          classes.push 'reversed' if reversed
          classes.join ' '
        )

        box.transition()
          .duration(duration)
          .attr('x', 0)
          .attr('y', (d) ->
            if reversed
              return y(d.get(progress.end) + barHeight)
            else
              return y(d.get(progress.start) + barHeight)
          ).attr('width', barWidth)
          .attr('height', (d) ->
            return y(0) - y(barHeight))

        center = bar.selectAll('.center').data([d])
        center.enter().append('line')
        center.attr('class', 'center')
        center.transition()
          .duration(duration)
          .attr('x1', barWidth / 2)
          .attr('y1', (d) -> if reversed then y(d.get(progress.start)) else y(d.get(progress.end)))
          .attr('x2', barWidth / 2)
          .attr('y2', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))

        whisker = bar.selectAll('.whisker').data([d])
        whisker.enter().append('line')
        whisker.attr('class', 'whisker')
        whisker.transition()
          .duration(duration)
          .attr('x1', 2)
          .attr('y1', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))
          .attr('x2', barWidth - 2)
          .attr('y2', (d) -> y(d.get(Visio.Algorithms.GOAL_TYPES.target)))

      )

    boxes.exit().remove()

  render.data = (_data) ->
    return data unless arguments.length
    data = _data
    render

  render.isPerformance = (_isPerformance) ->
    return isPerformance unless arguments.length
    isPerformance = _isPerformance
    goal = Visio.Algorithms.GOAL_VALUES.target if isPerformance
    render

  render.progress = (_progress) ->
    return [progress.start, progress.end].join('-') unless arguments.length
    progress = { start: _progress.split('-')[0], end: _progress.split('-')[1] }
    render

  render.goalType = (_goalType) ->
    return goalType unless arguments.length
    goalType = _goalType
    render

  sort = (a, b) ->
    reversedA = if a.get(progress.start) > a.get(progress.end) then -1 else 1
    reversedB = if b.get(progress.start) > b.get(progress.end) then -1 else 1
    (reversedA * scaledBarHeight(a)) - (reversedB * scaledBarHeight(b))

  scaledBarHeight = (d) ->
    y.domain [0, +d.get(goalType)]
    v = Math.abs(+d.get(progress.start) - +d.get(progress.end))
    y(v)


  render

