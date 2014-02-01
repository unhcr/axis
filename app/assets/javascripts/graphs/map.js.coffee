Visio.Figures.map = (config) ->
  margin = config.margin
  width = config.width - margin.left - margin.right
  height = config.height - margin.top - margin.bottom

  scale = 500

  views = {}

  zoomMax = 2.2
  zoomMin = 0.5

  translateExtent =
    left: 843
    right: -743
    top: 880
    bottom: -680

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

  expanded = null

  zoomStep = .4



  zoomed = () ->
    scale = if d3.event && d3.event.scale then d3.event.scale else zoom.scale()

    translate = if d3.event && d3.event.translate then d3.event.translate else zoom.translate()

    deltaWidth = width - width / scale
    deltaHeight = height - height / scale

    absTranslateX = translate[0] / scale
    absTranslateY = translate[1] / scale


    if absTranslateX < translateExtent.right - deltaWidth
      translate[0] = (translateExtent.right - deltaWidth) * Math.abs(scale)
    else if absTranslateX > translateExtent.left
      translate[0] = translateExtent.left * Math.abs(scale)

    if absTranslateY < translateExtent.bottom - deltaHeight
      translate[1] = (translateExtent.bottom  - deltaHeight) * Math.abs(scale)
    else if absTranslateY > translateExtent.top
      translate[1] = translateExtent.top * Math.abs(scale)

    $('.country').css('stroke-width', .5 / scale + 'px')

    g.attr("transform","translate(#{translate.join(",")})scale(#{scale})")
    g.select('.background-rect')
      .attr('x', -(translate[0] / scale))
      .attr('y', -(translate[1] / scale))
      .attr('width', width / scale)
      .attr('height', height / scale)

    for key, value of views
      value.render(true)

  zoom = d3.behavior.zoom()
    .scaleExtent([.5, 2.2])
    .on("zoom", zoomed)

  render = () ->
    world = g.selectAll('.country')
      .data(data)

    world.enter().append 'path'

    world.attr('class', (d) ->
      ['country', d.properties.adm0_a3].join(' '))
      .attr('d', path)
      .on('click', (d) ->
        iso3 = d.properties.adm0_a3
        if expanded && views[iso3] && expanded.model.id == views[iso3].model.id
          if expanded.isShrunk()
            expanded.expand()
          else
            expanded.shrink()
        else
          expanded.shrink() if expanded
          expanded = views[d.properties.adm0_a3]
          return unless expanded

          expanded.expand()
      )

    centerData = Visio.manager.get(Visio.Syncables.PLANS.plural).filter (plan) ->
      plan.get('country') and plan.get('year') == Visio.manager.year()

    centers = g.selectAll('.center')
      .data(centerData, (d) -> d.id)

    centers.enter().append 'circle'

    centers.attr('class', (d) ->
      classList = ['center', d.get('country').iso3, 'transparent']
      classList.join(' '))
      .attr('cx', (d) ->
        return projection([d.get('country').latlng[1], d.get('country').latlng[0]])[0]
      )
      .attr('cy', (d) ->
        return projection([d.get('country').latlng[1], d.get('country').latlng[0]])[1]
      )
      .attr('r', 3)
      .each((d) ->
        unless views[d.get('country').iso3]
          views[d.get('country').iso3] = new Visio.Views.MapTooltipView({ model: d, point: @ })
      )

  render.zoomIn = () ->
    scale = zoom.scale()
    scale = if scale + zoomStep > zoom.scaleExtent()[1] then zoom.scaleExtent()[1] else scale + zoomStep
    zoom.scale(scale)
    zoomed()

  render.zoomOut = () ->
    scale = zoom.scale()
    scale = if scale - zoomStep < zoom.scaleExtent()[0] then zoom.scaleExtent()[0] else scale - zoomStep
    zoom.scale(scale)
    zoomed()

  render.filterTooltips = (plan_ids) ->
    for key, value of views
      id = value.model.id
      if (not plan_ids? || _.isEmpty(plan_ids) || _.include(plan_ids, id)) && value.isCurrentYear()
        value.show()
        value.render(false)
      else
        value.hide()

  render.pan = (dx, dy) ->
    translate = zoom.translate()
    zoom.translate [translate[0] + dx, translate[1] + dy]
    zoomed()

  render.mapJSON = (mapJSON) ->
    data = topojson.feature(mapJSON, mapJSON.objects.world_50m).features

  render.clearTooltips = () ->
    for key, value of views
      value.close()
    views = {}

  render.refreshTooltips = () ->
    for key, value of views
      value.render(true)

  svg.call zoom


  return render


