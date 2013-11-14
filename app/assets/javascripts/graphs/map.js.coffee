Visio.Graphs.map = (config) ->
  margin = config.margin
  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  scale = 500

  zoomMax = 2.2
  zoomMin = 0.5

  projection = d3.geo.mercator()
    .scale(scale)
    .translate([width / 2, height / 2])
    .precision(0.1)

  path = d3.geo.path()
    .projection(projection)

  selection = config.selection

  data = config.mapJSON.features

  svg = selection.append('svg')
    .attr('width', config.width)
    .attr('height', config.height)

  g = svg.append('g')
    .attr('transform', "translate(#{margin.left}, #{margin.top})")

  g.append('rect')
    .attr('x', 0)
    .attr('y', 0)
    .attr('width', width)
    .attr('height', height)
    .attr('class', 'background-rect')

  zoom = d3.behavior.zoom()
    .on("zoom", () ->
      if d3.event.scale < zoomMin
        scale = zoomMin
      else if d3.event.scale > zoomMax
        scale = zoomMax
      else
        scale = d3.event.scale

      translate = d3.event.translate
      console.log scale
      console.log translate
      g.attr("transform","translate(#{translate.join(",")})scale(#{scale})")
      g.select('.background-rect')
        .attr('x', -(translate[0] / scale))
        .attr('y', -(translate[1] / scale))
        .attr('width', width / scale)
        .attr('height', height / scale))

  render = () ->
    world = g.selectAll('.country')
      .data(data)

    world.enter().append 'path'

    world.attr('class', (d) ->
      ['country'].join(' '))
      .attr('d', path)

  svg.call zoom


  return render


