class Visio.Figures.Map extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.MAP

  className: 'map-container'

  templateTooltip: HAML['tooltips/map']

  initialize: (config) ->

    super config

    @scale = 400

    @collection or= new Visio.Collections.Operation()
    @zoomMax = 2.2
    @zoomMin = 0.5
    @strokeMin = .5
    @strokeMax = 2

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
    end = d3.rgb('rgb(253, 52, 156)')
    @i = d3.interpolate start, end

    @scale = d3.scale.linear()
      .range([0, 1])

    scenarioValues = {}
    scenarioValues[Visio.Scenarios.AOL] = false
    scenarioValues[Visio.Scenarios.OL] = true

    @category = d3.scale.ordinal()
      .domain([
        Visio.Algorithms.ALGO_RESULTS.fail,
        Visio.Algorithms.ALGO_RESULTS.ok,
        Visio.Algorithms.ALGO_RESULTS.success,
        Visio.Algorithms.STATUS.missing
      ])
      .range(['#c6302a', 'rgb(242, 211, 25)', 'rgb(70, 190, 30)', 'rgb(133, 135, 134)'])

    values =
      selectedBudget: true,
      selectedExpenditureRate: false
      selectedSituationAnalysis: false
      selectedPerformanceAchievement: false
      selectedImpactAchievement: false
      selectedPopulation: false

    # Delete values that aren't of use for indicator page
    if Visio.manager.get('indicator')?.get('is_performance')
      delete values['selectedImpactAchievement']
      delete values['selectedSituationAnalysis']
    else if Visio.manager.get('indicator') and not Visio.manager.get('indicator').get('is_performance')
      delete values['selectedPerformanceAchievement']

    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: scenarioValues
        classback: (name, attr) =>
          @render()
      },
      {
        id: 'algorithm'
        filterType: 'radio'
        values: values
        human: {
          selectedExpenditureRate: 'Expenditure Rate',
          selectedBudget: 'Budget'
          selectedSituationAnalysis: 'Impact Criticality'
          selectedPerformanceAchievement: 'Performance Achievement'
          selectedImpactAchievement: 'Impact Achievement'
          selectedPopulation: 'Populations'
        }
        callback: (name, attr) =>
          @selectedDatum.set 'd', null
          @render()
      }

    ])

    @zoomStep = .4

    @zoom = d3.behavior.zoom()
      .scaleExtent([.5, 2.2])
      .on("zoom", @zoomed)

    @svg.call @zoom

  dataAccessor: => @model

  selectable: true

  setupFns: [ { name: 'getMap' } ]

  render: ->

    self = @

    algorithm = @filters.get('algorithm').active()

    filtered = @filtered @collection
    @scale.domain @algorithmDomain(filtered) unless algorithm == 'selectedSituationAnalysis'

    @model.getMap().done (map) =>
      features = topojson.feature(map, map.objects.world_50m).features

      world = @g.selectAll('.country')
        .data features

      world.enter().append 'path'

      world.attr('class', (d) ->

        classList = ['country', d.properties.adm0_a3]

        operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
        classList.push 'available' if operation

        classList.join ' '
        )
        .attr('d', @path)
        .on('mouseenter', (d) ->
          operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
          return unless operation
          self.$el.find(".center.#{operation.get('country').iso3}").tipsy('show'))
        .on('mouseout', (d) ->
          operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
          return unless operation
          self.$el.find(".center.#{operation.get('country').iso3}").tipsy('hide'))

      world
        .transition()
        .duration(Visio.Durations.FAST)
        .style('fill', (d) ->
          operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
          return unless operation

          value = self.algorithmValue(operation)

          switch algorithm
            when 'selectedSituationAnalysis'
              return self.category value
            else
              return self.i self.scale(value)
        )

      world.on('click', (d) ->
        operation = _.find filtered, (o) -> o.get('country').iso3 == d.properties.adm0_a3
        return unless operation

        d3.select(self.el).selectAll('.country').classed 'selected', false

        if self.selectedDatum.get('d')?.id == operation.id
          self.selectedDatum.set 'd', null
        else
          self.selectedDatum.set 'd', operation
          d3.select(@).classed 'selected', true
          d3.select(@).moveToFront()
        self.scaleStroke()

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
      .attr('original-title', (d) =>
        label = @filters.get('algorithm').get('human')[algorithm]
        value = @algorithmValue(d)

        formatted = switch algorithm
          when 'selectedExpenditureRate', 'selectedPerformanceAchievement', 'selectedImpactAchievement'
            Visio.Formats.PERCENT value
          when 'selectedBudget'
            Visio.Formats.MONEY value
          when 'selectedSituationAnalysis'
            Visio.Utils.humanMetric(value)
          when 'selectedPopulation'
            Visio.Formats.COMMA value

        @templateTooltip
          operation: d
          label: label
          value: formatted
      )

    @$el.find('.center').tipsy()
    @tipsyHeaderBtns()
    @

  algorithmValue: (operation) ->
    algorithm = @filters.get('algorithm').active()
    switch algorithm
      when 'selectedSituationAnalysis'
        value = operation[algorithm] Visio.manager.year(), @filters
        value.category
      when 'selectedImpactAchievement', 'selectedPerformanceAchievement'
        value = operation[algorithm] Visio.manager.year(), @filters
        value.result
      else
        value = operation[algorithm] Visio.manager.year(), @filters

  algorithmDomain: (filtered) ->
    algorithm = @filters.get('algorithm').active()
    switch algorithm
      when 'selectedSituationAnalysis'
        # Have to use a different scale for this one anyways
        console.log 'noop'
      when 'selectedImpactAchievement', 'selectedPerformanceAchievement', 'selectedExpenditureRate'
        [0, 1]
      else
        [0, d3.max(filtered, (d) => @algorithmValue(d))]

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

    @scaleStroke scale

    @g.attr("transform","translate(#{translate.join(",")})scale(#{scale})")
    @g.select('.background-rect')
      .attr('x', -(translate[0] / scale))
      .attr('y', -(translate[1] / scale))
      .attr('width', @adjustedWidth / scale)
      .attr('height', @adjustedHeight / scale)

    @zoom.translate translate

    for key, value of @views
      value.render(true)

  scaleStroke: (scale) =>
    scale or= @zoom.scale()
    $('.country').css('stroke-width', @strokeMin / scale + 'px')
    $('.country.selected').css('stroke-width', @strokeMax / scale + 'px')

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

  selectedable: false
