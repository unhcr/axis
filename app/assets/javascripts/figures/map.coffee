class Visio.Figures.Map extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.MAP

  className: 'map-container'

  initialize: (config) ->

    super config

    @scale = 500

    @views = {}

    @collection or= new Visio.Collections.Plan()
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

    @zoomStep = .4

    @zoom = d3.behavior.zoom()
      .scaleExtent([.5, 2.2])
      .on("zoom", @zoomed)

    @svg.call @zoom

  dataAccessor: => @model

  selectable: false

  setupFns: [ { name: 'getMap' } ]

  render: ->

    self = @

    filtered = @filtered @collection
    features = topojson.feature(@model.get('map'), @model.get('map').objects.world_50m).features

    world = @g.selectAll('.country')
      .data features

    world.enter().append 'path'

    world.attr('class', (d) ->
      ['country', d.properties.adm0_a3].join(' '))
      .attr('d', @path)
      .on('click', (d) ->
        d3.select(self.el).selectAll('.country.active').classed 'active', false
        window.location.href = "/operation/#{d.properties.adm0_a3}"

        #el = d3.select @
        #iso3 = d.properties.adm0_a3
        #if self.expanded && self.views[iso3] && self.expanded.model.id == self.views[iso3].model.id
        #  if self.expanded.isShrunk()
        #    self.expanded.expand()
        #    el.classed 'active', true
        #  else
        #    self.expanded.shrink()
        #    el.classed 'active', false
        #else
        #  self.expanded.shrink() if self.expanded
        #  self.expanded = self.views[d.properties.adm0_a3]
        #  return unless self.expanded

        #  self.expanded.expand()
        #  el.classed 'active', true
      )

    centers = @g.selectAll('.center')
      .data(filtered, (d) -> d.id)

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
          self.views[d.get('country').iso3] = new Visio.Views.MapTooltipView({
            map: self, model: d, point: @ })
      )

    @filterTooltips()

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

  getMap: =>
    @model.getMap()

  zoomIn: =>
    scale = @zoom.scale()
    scale = if scale + @zoomStep > @zoom.scaleExtent()[1] then @zoom.scaleExtent()[1] else scale + @zoomStep
    @zoom.scale scale
    @zoomed()

  zoomOut: =>
    scale = @zoom.scale()
    scale = if scale - @zoomStep < @zoom.scaleExtent()[0] then @zoom.scaleExtent()[0] else scale - @zoomStep
    @zoom.scale(scale)
    @zoomed()


  filterTooltips: () =>
    filtered = @filtered @collection
    filteredCollection = new Visio.Collections.Plan filtered
    for key, value of @views
      id = value.model.id
      if filteredCollection.get(id)?
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

  filtered: (collection) =>
    selectedStrategies = _.chain(Visio.manager.get('selected_strategies'))
      .keys().map((id) -> +id).value()

    collection.filter (plan) ->
      plan.get('year') == Visio.manager.year() and
      plan.get('country') and
      (_.isEmpty(selectedStrategies) or
      _.every(selectedStrategies, (id) -> _.include(plan.get('strategy_ids'), id)))

  refreshTooltips: ->
    for key, value of @views
      value.render(true)
