class Visio.Figures.Map extends Visio.Figures.Base

  type: Visio.FigureTypes.MAP

  initialize: (config) ->

    super config

    @scale = 500

    @views = {}

    @zoomMax = 2.2
    @zoomMin = 0.5

    @translateExtent =
      left: 843
      right: -743
      top: 880
      bottom: -680

    @projection = d3.geo.mercator()
      .center([0, 35])
      .scale(@scale)
      .translate([@adjustedWidth / 2, @adjustedHeight / 2])
      .precision(0.1)

    @path = d3.geo.path()
      .projection(@projection)

    @g.append('rect')
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', @adjustedWidth)
      .attr('height', @adjustedHeight)
      .attr('class', 'background-rect')

    expanded = null

    zoomStep = .4

    @zoom = d3.behavior.zoom()
      .scaleExtent([.5, 2.2])
      .on("zoom", @zoomed)

    @svg.call @zoom

  render: ->

    self = @

    filtered = @filtered @model
    world = @g.selectAll('.country')
      .data(filtered)

    world.enter().append 'path'

    world.attr('class', (d) ->
      ['country', d.properties.adm0_a3].join(' '))
      .attr('d', @path)
      .on('click', (d) =>
        iso3 = d.properties.adm0_a3
        if @expanded && @views[iso3] && @expanded.model.id == @views[iso3].model.id
          if @expanded.isShrunk()
            @expanded.expand()
          else
            @expanded.shrink()
        else
          @expanded.shrink() if @expanded
          @expanded = @views[d.properties.adm0_a3]
          return unless @expanded

          @expanded.expand()
      )

    centerData = Visio.manager.get(Visio.Syncables.PLANS.plural).filter (plan) ->
      plan.get('country') and plan.get('year') == Visio.manager.year()

    centers = @g.selectAll('.center')
      .data(centerData, (d) -> d.id)

    centers.enter().append 'circle'

    centers.attr('class', (d) ->
      classList = ['center', d.get('country').iso3, 'transparent']
      classList.join(' '))
      .attr('cx', (d) =>
        return @projection([d.get('country').latlng[1], d.get('country').latlng[0]])[0]
      )
      .attr('cy', (d) =>
        return @projection([d.get('country').latlng[1], d.get('country').latlng[0]])[1]
      )
      .attr('r', 3)
      .each((d) ->
        unless self.views[d.get('country').iso3]
          self.views[d.get('country').iso3] = new Visio.Views.MapTooltipView({ model: d, point: @ })
      )

    @

  zoomed: =>
    scale = if d3.event && d3.event.scale then d3.event.scale else @zoom.scale()

    translate = if d3.event && d3.event.translate then d3.event.translate else @zoom.translate()

    deltaWidth = @adjustedWidth - @adjustedWidth / scale
    deltaHeight = @adjustedHeight - @adjustedHeight / scale

    absTranslateX = translate[0] / scale
    absTranslateY = translate[1] / scale


    if absTranslateX < @translateExtent.right - deltaWidth
      translate[0] = (@translateExtent.right - deltaWidth) * Math.abs(scale)
    else if absTranslateX > @translateExtent.left
      translate[0] = @translateExtent.left * Math.abs(scale)

    if absTranslateY < @translateExtent.bottom - deltaHeight
      translate[1] = (@translateExtent.bottom  - deltaHeight) * Math.abs(scale)
    else if absTranslateY > @translateExtent.top
      translate[1] = @translateExtent.top * Math.abs(scale)

    $('.country').css('stroke-width', .5 / scale + 'px')

    @g.attr("transform","translate(#{translate.join(",")})scale(#{scale})")
    @g.select('.background-rect')
      .attr('x', -(translate[0] / scale))
      .attr('y', -(translate[1] / scale))
      .attr('width', @adjustedWidth / scale)
      .attr('height', @adjustedHeight / scale)

    @zoom.translate translate

    for key, value of @views
      value.render(true)

  zoomIn: =>
    scale = zoom.scale()
    scale = if scale + @zoomStep > @zoom.scaleExtent()[1] then @zoom.scaleExtent()[1] else scale + @zoomStep
    @zoom.scale(scale)
    @zoomed()

  zoomOut: =>
    scale = @zoom.scale()
    scale = if scale - @zoomStep < @zoom.scaleExtent()[0] then @zoom.scaleExtent()[0] else scale - @zoomStep
    @zoom.scale(scale)
    @zoomed()


  filterTooltips: (plan_ids) =>
    for key, value of @views
      id = value.model.id
      if (not plan_ids? || _.isEmpty(plan_ids) || _.include(plan_ids, id)) && value.isCurrentYear()
        value.show()
        value.render(false)
      else
        value.hide()

  pan: (dx, dy) =>
    translate = @zoom.translate()
    @zoom.translate [translate[0] + dx, translate[1] + dy]
    @zoomed()

  clearTooltips: =>
    for key, value of @views
      value.close()
    @views = {}

  filtered: (model) =>
    topojson.feature(model.toJSON(), model.toJSON().objects.world_50m).features

  refreshTooltips: ->
    for key, value of @views
      value.render(true)
