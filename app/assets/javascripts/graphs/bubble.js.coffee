Visio.Graphs.bubble = (config) ->

  margin =
    top: 50,
    bottom: 50,
    left: 50,
    right: 50

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  selection = config.selection

  svg = selection.append('svg')
    .attr('width', width)
    .attr('height', height)

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

  parameters = config.parameters

  render = () ->

    maxBudget = 0

    data = parameters.map (parameter) ->
      achievement = parameter.selectedAchievement()
      value = if achievement then achievement.result else 0
      datum = {
        budget: parameter.selectedBudget()
        achievement: value
        population: Math.random() * 1000000
      }
      maxBudget = datum.budget if datum.budget > maxBudget
      return datum

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


  return render


