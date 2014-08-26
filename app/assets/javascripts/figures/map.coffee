class Visio.Figures.Map extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.MAP

  className: 'map-container'

  initialize: (config) ->

    super config

    @scale = 400

    @views = {}

    @collection or= new Visio.Collections.Operation()
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

    start = d3.rgb('#fff')
    end = d3.rgb('#000')
    @i = d3.interpolate start, end

    @scale = d3.scale.linear()
      .range([0, 1])

    @algorithm = 'selectedBudget'
    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'algorithm'
        filterType: 'radio'
        values: {
          selectedBudget: true,
          selectedExpenditureRate: false
        }
        human: { selectedExpenditureRate: 'Expenditure Rate', selectedBudget: 'Budget' }
        callback: (name, attr) =>
          @algorithm = name
          if @algorithm == 'selectedBudget'
            @xAxis.tickFormat Visio.Formats.SI_SIMPLE
          else
            @xAxis.tickFormat Visio.Formats.PERCENT_NOSIGN
          @render()

      }

    ])
    #@g.append('rect')
    #  .attr('x', 0)
    #  .attr('y', 0)
    #  .attr('width', @adjustedWidth)
    #  .attr('height', @adjustedHeight)
    #  .attr('class', 'background-rect')

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
    @scale.domain [0, d3.max(filtered, (d) => d[@algorithm]())]
    @model.getMap().done (map) =>
      features = topojson.feature(map, map.objects.world_50m).features

      world = @g.selectAll('.country')
        .data features

      world.enter().append 'path'

      world.attr('class', (d) ->

        ['country', d.properties.adm0_a3].join(' ')
        )
        .attr('d', @path)
        .style('fill', (d) ->
          operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
          return unless operation

          value = operation[self.algorithm]()
          console.log(self.i self.scale(value))
          self.i self.scale(value)
        )
        .on('click', (d) ->
          d3.select(self.el).selectAll('.country.active').classed 'active', false
        )

    #centers = @g.selectAll('.center')
    #  .data(filtered, (d) -> d.id)

    #centers.enter().append 'circle'

    #centers.attr('class', (d) ->
    #  classList = ['center', d.get('country').iso3, 'transparent']
    #  classList.join(' '))
    #  .attr('cx', (d) =>
    #    return @projection([d.get('country').latlng[1], d.get('country').latlng[0]])[0]
    #  )
    #  .attr('cy', (d) =>
    #    return @projection([d.get('country').latlng[1], d.get('country').latlng[0]])[1]
    #  )
    #  .attr('r', 3)
    #  .each((d) ->
    #    unless self.views[d.get('country').iso3]
    #      self.views[d.get('country').iso3] = new Visio.Views.MapTooltipView({
    #        map: self, model: d, point: @ })
    #  )

    #@filterTooltips()

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


  pan: (dx, dy) =>
    translate = @zoom.translate()
    @zoom.translate [translate[0] + dx, translate[1] + dy]
    @zoomed()

  filtered: (collection) =>
    collection.filter (o) -> o.get('country')?
