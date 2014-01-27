Visio.Figures.sparkBarGraph = (config) ->
  negativeLength = 2
  margin = config.margin
  margin.left = 0
  margin.right = negativeLength

  width = config.width - margin.left - margin.right

  selection = config.selection

  barWidth = config.barWidth || 10

  height = barWidth * 4

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', height + margin.top + margin.bottom)

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")


  x = d3.scale.linear()
    .domain([50, 0])
    .range([0, width])

  y = d3.scale.linear()
    .domain([0, 40])
    .range([height, 0])

  data = []


  render = () ->

    bars = g.selectAll('.bar').data(data)
    bars.enter().append('rect')
    bars.attr('class', (d) ->
      ['bar', d.key].join ' ' )
    bars.transition().duration(Visio.Durations.FAST)
      .attr('x', (d) -> x(d.value))
      .attr('y', (d, i) -> y(i * barWidth) - barWidth)
      .attr('width', (d) -> if d.value then x(0) - x(d.value) else negativeLength)
      .attr('height', barWidth)

    bars.exit().remove()

  render.data = (_data) ->
    return data if arguments.length == 0
    data = d3.entries(_data.counts)
    render

  render

