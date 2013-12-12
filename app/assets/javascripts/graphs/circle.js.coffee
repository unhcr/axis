Visio.Graphs.circle = (config) ->
  margin = config.margin

  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom
  twoPi = 2 * Math.PI

  arc = d3.svg.arc()
    .startAngle(0)
    .innerRadius((height / 2) - 6.5)
    .outerRadius(height / 2)

  selection = config.selection

  resultType = config.resultType

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)
    .append('g')
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
    .append('g')
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

  meter = svg.append("g")
    .attr("class", "progress-meter")

  meter.append("path")
    .attr("class", "background")
    .attr("d", arc.endAngle(twoPi))

  foreground = meter.append("path")
    .attr("class", "foreground #{resultType}")

  text = meter.append("text")
    .attr("text-anchor", "middle")
    .attr("dy", ".35em")

  oldPercent = percent = config.percent || 1

  oldNumber = number = config.number

  render = () =>
    i = d3.interpolate(oldPercent, percent)
    svg.transition()
      .duration(Visio.Durations.FAST)
      .tween("percent", () ->
        return (t) ->
          percent = i(t)
          foreground.attr('d', arc.endAngle(twoPi * percent)))

    console.log text[0][0]
    $(text[0][0]).countTo
      from: oldNumber
      to: number
      speed: Visio.Durations.FAST

    oldPercent = percent
    oldNumber = number

  render.percent = (_percent) =>
    return percent if !arguments
    percent = _percent || 0
    return render

  render.number = (_number) =>
    return number if !arguments
    number = if _.isNumber(_number) then _number else '?'
    return render

  return render

