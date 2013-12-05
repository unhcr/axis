Visio.Graphs.circleFn = (config) ->
  margin =
    top: 5,
    bottom: 5,
    left: 5,
    right: 5

  width = (config.width || 200) - margin.left - margin.right
  height = (config.height || 110) - margin.top - margin.bottom
  twoPi = 2 * Math.PI

  arc = d3.svg.arc()
    .startAngle(0)
    .innerRadius((height / 2) - 10)
    .outerRadius(height / 2)

  selection = config.selection

  svg = selection.append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  meter = svg.append("g")
    .attr("class", "progress-meter")

  meter.append("path")
    .attr("class", "background")
    .attr("d", arc.endAngle(twoPi))

  foreground = meter.append("path")
    .attr("class", "foreground")

  text = meter.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", ".35em")

  oldPercent = percent = config.percent || 1

  number = config.number


  render = () =>
    i = d3.interpolate(oldPercent, percent)
    d3.transition()
      .duration(500)
      .tween("percent", () ->
        return (t) ->
          percent = i(t)
          foreground.attr('d', arc.endAngle(twoPi * percent)))

    text.text(number)
    oldPercent = percent

  render.percent = (_percent) =>
    return percent if !arguments
    percent = _percent
    return @

  render.number = (_number) =>
    return number if !arguments
    number = _number
    return @

  return render

