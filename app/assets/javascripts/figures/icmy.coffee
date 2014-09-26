# Indicator Criticality Multiple Year
class Visio.Figures.Icmy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.ICMY

  initialize: (config) ->
    values = {}
    values['selectedSituationAnalysis'] = true
    values['selectedImpactAchievement'] = false
    values['selectedPerformanceAchievement'] = false
    @filters = new Visio.Collections.FigureFilter([
      {
        id: 'algorithm'
        filterType: 'radio'
        values: values
        human: {
          'selectedSituationAnalysis': 'Impact Criticality',
          'selectedImpactAchievement': 'Impact Achievement'
          'selectedPerformanceAchievement': 'Performance Achievement' }
        callback: (name, attr) =>
          @algorithm = name
          @isPerformance = @algorithm == 'selectedOutputAchievement'

          @filters.get('is_performance').filter @isPerformance, true

          @renderSelectedComponents null, []

          @render()
      },
      {
        id: 'is_performance'
        filterType: 'radio'
        values: { true: false, false: true }
        human: { true: 'performance', false: 'impact' }
        hidden: true
      }
    ])

    config.algorithm or= 'selectedSituationAnalysis'
    opts = {}
    if config.isPdf
      opts.keys = switch config.algorithm
        when 'selectedPerformanceAchievement', 'selectedImpactAchievement'
          Visio.Algorithms.THRESHOLDS
        when 'selectedSituationAnalysis'
          Visio.Algorithms.CRITICALITIES

    super config, opts
    self = @

    @tooltip = null
    @tickPadding = 20

    @svg.on('mouseleave', () ->
      self.tooltip.close() if self.tooltip?
      self.tooltip = null
      d3.select(@).selectAll('.point').transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    )

    @x = d3.scale.ordinal()
      .rangePoints([0, @adjustedWidth])
      .domain(Visio.manager.get('yearList'))

    @y = d3.scale.linear()
      .domain([0, 1])
      .range([@adjustedHeight, 0])

    @lineFn = d3.svg.line()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))

    @domain = null

    @voronoiFn = d3.geom.voronoi()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))
      .clipExtent([[-@margin.left, -@margin.top], [@adjustedWidth + @margin.right, @adjustedHeight + @margin.bottom]])

    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient('bottom')
      .ticks(6)
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .innerTickSize(14)
      .tickFormat((d) -> return d * 100)
      .tickPadding(@tickPadding)
      .tickSize(-@adjustedWidth)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("y", -60)
        .attr('transform', "translate(-#{@tickPadding}, 0)")
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @yAxisLabel()

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")


    # Legend Setup
    if @isPdf
      @legendView = new Visio.Legends.IcmyPdf
        figure: @
        collection: @collection
        selected: @selected
    else
      @legendView = new Visio.Legends.Icmy()


  render: ->
    filtered = @filtered @collection

    lines = @g.selectAll('.ic-line').data(filtered, (d) -> d.category)
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('class', (d) -> ['ic-line', "ic-line-#{d.category}", d.category].join(' '))
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('d', (d) => if d.length then @lineFn(d) else 'M0 0')

    lines.exit().remove()

    voronoi = @g.selectAll('.voronoi').data(@voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', @polygon)
      .on('click', (d) => @onMouseclickVoronoi(d, filtered) )
      .on 'mouseenter', (d) =>
        pointData = _.chain(filtered).flatten().where({ year: d.point.year }).value()
        points = @g.selectAll('.point').data pointData
        points.enter().append 'circle'
        points
          .attr('r', 5)
          .attr('class', (d) -> ['point', d.category].join(' '))
        points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
          .attr('cx', (d) => @x(d.year))
          .attr('cy', (d) => @y(d.amount))
        points.exit().remove()


        if @tooltip?
          @tooltip.year = d.point.year
          @tooltip.collection = new Backbone.Collection(pointData)
          @tooltip.render(true)
        else
          @tooltip = new Visio.Views.IcmyTooltip
            figure: @
            year: d.point.year
            collection: new Backbone.Collection(pointData)
          @tooltip.render()

    voronoi.exit().remove()

    @g.select('.x.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@xAxis)

    @g.selectAll('.x.axis text')
      .attr 'class', (d, i) =>
        'label-' + @x.domain()[i]

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)

    @g.select('.y.axis text')
      .html =>
        @yAxisLabel()

    @$el.find('.legend-container').html @legendView.render().el
    @

  mapFn: (lineData, idx, memo) =>
    _.each lineData, (d) ->
      d.numerator = d.amount
      d.denominator = memo["amount#{d.year}"]
      d.amount /= memo["amount#{d.year}"]
      d.amount = 0 if _.isNaN d.amount
    lineData

  transformFn: (collection) =>
    memo = []
    _.each Visio.manager.get('yearList'), (year) =>

      return if year > (new Date()).getFullYear()

      result = collection[@algorithm] year, @filters

      # Keeps track of total in that year
      memo["amount#{year}"] = 0 unless memo["amount#{year}"]?
      memo["amount#{year}"] += result.total

      for category, count of result.counts
        lineData = _.find memo, (d) -> d.category == category
        unless lineData?
          lineData = []
          lineData.amount = 0
          lineData.category = category
          memo.push lineData

        # Keeps track of total in that category
        lineData.amount += count

        datum = _.findWhere lineData, { year: year, category: category }
        found = datum?

        id = if collection.length == 1 then collection.at(0).id else null

        datum or=
          amount: 0
          year: year
          category: category
          summary: @summary
          model_id: id
          id_type: collection.name
          name: collection.toString()

        # Keeps track of total in that year for that category
        datum.amount += count

        lineData.push datum unless found

    return memo

  filtered: (collection) =>
    _.map @transformFn(collection), @mapFn

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  onMouseclickVoronoi: (d, filtered) =>

    if @selectedDatum.get('d') == d.point
      @renderSelectedComponents null, []
    else
      pointData = _.chain(filtered).flatten().where({ year: d?.point.year }).value()
      @renderSelectedComponents d.point, pointData

  renderSelectedComponents: (point, pointData) =>
    @selectedDatum.set 'd', point

    pointLineData = if @selectedDatum.get('d')? then [point.year] else []
    pointLine = @g.selectAll('.icmy-point-line').data pointLineData
    pointLine.enter().append 'line'
    pointLine.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('class', 'icmy-point-line')
      .attr('x1', (d) => @x(d))
      .attr('x2', (d) => @x(d))
      .attr('y1', (d) => 0)
      .attr('y2', (d) => @adjustedHeight)
    pointLine.exit().remove()

    pointShadows = @g.selectAll('.icmy-point-shadow-selected').data pointData
    pointShadows.enter().append 'circle'
    pointShadows
      .attr('r', 7)
      .attr('class', (d) ->
        ['icmy-point-shadow-selected', Visio.Utils.stringToCssClass(d.category)].join(' '))
    pointShadows.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    pointShadows.exit().remove()

    points = @g.selectAll('.icmy-point-selected').data pointData
    points.enter().append 'circle'
    points
      .attr('r', 5)
      .attr('class', (d) ->
        ['icmy-point-selected', Visio.Utils.stringToCssClass(d.category)].join(' '))
    points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    points.exit().remove()

  selectable: true

  previewable: true

  selectableData: =>
    (new Backbone.Collection(Visio.manager.get('yearList').map (year) -> { id: year })).models

  selectableLabel: (d, i) =>
    d.id

  select: (e, d, i) =>
    label = @g.select(".label-#{d.id}")
    isActive = label.classed 'active'
    label.classed 'active', not isActive

  yAxisLabel: =>
    value = @filters.get('algorithm').active()

    human = @filters.get('algorithm').get('human')[value]

    return @templateLabel
        title: human,
        subtitles: ['% of Progress']

  close: =>
    super
    console.log 'clsing'
    @tooltip?.close()
