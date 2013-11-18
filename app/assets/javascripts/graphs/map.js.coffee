Visio.Graphs.map = (config) ->
  margin = config.margin
  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  scale = 500

  zoomMax = 2.2
  zoomMin = 0.5

  translateExtent =
    left: 843
    right: -743
    top: 880
    bottom: -346

  projection = d3.geo.mercator()
    .center([0, 35])
    .scale(scale)
    .translate([width / 2, height / 2])
    .precision(0.1)

  path = d3.geo.path()
    .projection(projection)

  selection = config.selection

  if config.mapJSON
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
    .scaleExtent([.5, 2.2])
    .on("zoom", () ->
      scale = d3.event.scale

      translate = d3.event.translate

      absTranslateX = translate[0] / scale
      absTranslateY = translate[1] / scale


      if absTranslateX < translateExtent.left - width / scale
        translate[0] = (translateExtent.left - width / scale) * scale
      else if absTranslateX > translateExtent.left
        translate[0] = translateExtent.left * Math.abs(scale)

      if absTranslateY < translateExtent.bottom
        translate[1] = translateExtent.bottom * Math.abs(scale)
      else if absTranslateY > translateExtent.top
        translate[1] = translateExtent.top * Math.abs(scale)

      $('.country').css('stroke-width', .5 / scale + 'px')

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

  render.mapJSON = (mapJSON) ->
    data = mapJSON.features

  svg.call zoom


  return render


