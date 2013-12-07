Visio.Graphs.bubble = (config) ->

  margin =
    top: 50,
    bottom: 50,
    left: 100,
    right: 50

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection

  duration = 500

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)

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

  xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')
    .tickFormat(Visio.Formats.SI)
    .ticks(6)
    .innerTickSize(14)

  yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .ticks(5)
    .tickFormat((d) -> return if d then d * 100 else '0%')
    .innerTickSize(14)
    .tickPadding(20)

  parameters = config.parameters

  g.append('g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(0,0)')

  g.append('g')
    .attr('class', 'x axis')
    .attr('transform', "translate(0,#{height})")

  render = () ->

    maxBudget = 0

    data = parameters.map (parameter) ->
      achievement = parameter.selectedAchievement().result
      datum = {
        budget: parameter.selectedBudget()
        achievement: achievement
        population: Math.random() * 1000000
      }
      maxBudget = datum.budget if datum.budget > maxBudget
      return datum

    data = data.filter (d) ->
      return d.budget && d.achievement

    x.domain([0, maxBudget])

    bubbles = g.selectAll('.bubble')
      .data(data)

    bubbles.enter().append('circle')
    bubbles
      .attr('class', (d) ->
        return ['bubble'].join(' '))
      .attr('r', (d) ->
        return r(d.population))
      .attr('cy', (d) ->
        return y(d.achievement))
      .attr('cx', (d) ->
        return x(d.budget))

    bubbles.exit().remove()

    g.select('.x.axis')
      .transition()
      .duration(duration)
      .call(xAxis)

    g.select('.y.axis')
      .transition()
      .duration(duration)
      .call(yAxis)
      .selectAll('g')
        .attr('transform', (d) ->
          transform = Visio.Utils.parseTransform($(@).attr('transform'))
          translate = transform.translate

          return "translate(#{translate[0] - 20}, #{translate[1]})"
        )


  return render


