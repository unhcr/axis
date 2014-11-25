# Budget Multiple Year
class Visio.Figures.Bmy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.BMY

  initialize: (config) ->
    super config

    values = {}
    values[Visio.Scenarios.AOL] = false
    values[Visio.Scenarios.OL] = true

    groupByValues = {}

    groupByValues['scenario'] = false
    groupByValues['budget_type'] = true
    groupByValues['pillar'] = false

    @filters or= new Visio.Collections.FigureFilter([
      {
        id: 'normalized'
        filterType: 'checkbox'
        values: {
          normalized: false,
        }
        human: { normalized: 'Cost Per Beneficiary' }
        callback: =>
          @render()
      },
      {
        id: 'show_total'
        filterType: 'checkbox'
        values: { 'Show Total': true }
        callback: (name, attr) =>
          @render()
      },
      {
        id: 'group_by'
        filterType: 'radio'
        values: groupByValues
        callback: (name, attr) =>
          @groupBy = name
          @renderSelectedComponents null, []
          @render()
      },
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
        callback: => @render()
      },
      {
        id: 'pillar'
        filterType: 'checkbox'
        values: _.object(_.keys(Visio.Pillars), _.keys(Visio.Pillars).map(-> true))
        human: Visio.Pillars
        callback: => @render()
      },
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: values
        callback: => @render()
      }
    ])


    @tooltip = null

    self = @
    @svg.on('mouseleave', () ->
      self.tooltip.close() if self.tooltip?
      self.tooltip = null
      d3.select(@).selectAll('.point').transition().duration(Visio.Durations.VERY_FAST).attr('r', 0).remove()
    )

    @x = d3.scale.ordinal()
      .rangePoints([0, @adjustedWidth])
      .domain(Visio.manager.get('yearList'))

    @y = d3.scale.linear()
      .range([@adjustedHeight, 0])

    @lineFn = d3.svg.line()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))

    @domain = null

    @voronoiFn = d3.geom.voronoi()
      .x((d) => @x(d.year))
      .y((d) => @y(d.amount))
      .clipExtent([[-@margin.left, -@margin.top],
                   [@adjustedWidth + @margin.right, @adjustedHeight + @margin.bottom]])

    @isExport = if config.isExport? then config.isExport else false

    @xAxis = d3.svg.axis()
      .scale(@x)
      .orient('bottom')
      .ticks(6)
      .innerTickSize(14)

    @yAxis = d3.svg.axis()
      .scale(@y)
      .orient('left')
      .ticks(5)
      .tickFormat((d) -> if d == 0 then null else Visio.Formats.SI_SIMPLE(d))
      .innerTickSize(0)
      .tickPadding(22)
      .tickSize(-@adjustedWidth)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")
        .attr("y", 0)
        .attr('transform', 'translate(-20, -60)')
        .attr("dy", "-.21em")
        .style("text-anchor", "end")
        .html =>
          @yAxisLabel()


    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")

  render: ->
    filtered = @filtered (@model or @collection)
    normalized = @filters.get('normalized').filter('normalized')

    @y.domain [0, d3.max(_.flatten(filtered), (d) -> d.amount)]


    # Renders lines
    lines = @g.selectAll('.budget-line').data(filtered, (d) -> d[d.groupBy])
    lines.enter().append 'path'
    lines
      .each((d) -> d.sort((a, b) -> a.year - b.year))
      .attr('class', (d) ->
        clazz = Visio.Utils.stringToCssClass(d[d.groupBy])
        ['budget-line', "budget-line-#{clazz}", clazz].join(' '))
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('d', (d) => if d.length then @lineFn(d) else 'M0 0')

    lines.exit().remove()

    allPointData = []

    _.each filtered, (pointData) =>
      if pointData.length > 1 or pointData.length == 0
        return

      allPointData = allPointData.concat pointData

    # Render circles for any line that only has one point
    points = @g.selectAll(".budget-point")
      .data(allPointData, (d) -> "#{d[d.groupBy]}#{d.year}")

    points.enter().append('circle')
    points.attr('r', 3)
      .attr('class', (d) ->
        clazz = Visio.Utils.stringToCssClass(d[d.groupBy])
        ['budget-point',
          "budget-point-#{d.year}",
          clazz,
          "budget-point-#{clazz}"].join(' '))
      .transition()
      .duration(Visio.Durations.FAST)
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))

    points.exit().remove()

    # For selecting line segments
    #
    voronoi = @g.selectAll('.voronoi').data(@voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', @polygon)
      .on('mouseenter', (d) => @onMouseenterVoronoi(d, filtered) )
      .on('click', (d) => @onMouseclickVoronoi(d, filtered) )

    if @isExport
      voronoi.on('click', (d, i) =>
        # ASSUMES DETERMINISTIC FLATTEN FUNCTION
        count = 0
        lineIndex = null
        _.each filtered, (lineArray, lineArrayIndex) ->
          _.each lineArray, (lineDatum) ->
            lineIndex = lineArrayIndex if count == i
            count += 1

        $.publish "active.#{@figureId()}", [d.point, lineIndex])

    voronoi.exit().remove()

    @g.select('.x.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@xAxis)

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)

    @g.select('.y.axis text')
      .html =>
        @yAxisLabel()

    @renderLegend()

    @tipsyHeaderBtns()
    @

  # Transforms parameter into data for the BMY graph
  # Data structure:
  # [ [ { amount: xxx, groupby: <group>, year: 2012 }, { .. year: 2013 }, ... ] ... ]
  reduceFn: (memo, budget) =>
    if not budget.get('year') or Visio.manager.get('yearList').indexOf(budget.get('year')) == -1
      console.warn 'No year for budget: ' + budget.id
      return memo

    return memo if @filters.isFiltered budget


    groupBy = @filters.get('group_by').active()

    # Add groupBy array
    lineData = _.find memo, (array) => array[groupBy] == budget.get groupBy
    unless lineData
      lineData = []
      lineData['groupBy'] = groupBy
      lineData[groupBy] = budget.get groupBy
      memo.push lineData unless @filters.isFiltered budget


    # Add line datum
    datum = _.findWhere lineData, { year: budget.get 'year' }
    unless datum
      datum = { amount: 0, year: budget.get('year') }
      datum['groupBy'] = groupBy
      datum[groupBy] = budget.get groupBy
      datum.summary = false


      if @modelOrCollection instanceof Backbone.Collection
        datum.model_id = budget.get groupBy
        datum.id_type = Visio.Utils.parameterBySingular(groupBy.replace('_id',''))
        datum.name = Visio.manager.get(datum.id_type.plural).get(datum.model_id)?.toString()
      else
        datum.model_id = @modelOrCollection.id
        datum.id_type = @modelOrCollection.name
        datum.name = @modelOrCollection.toString()


      lineData.push datum unless @filters.isFiltered budget


    datum.amount += budget.get('amount') / (@populations[budget.get('year')] or 1)

    if @filters.get('show_total').filter('Show Total')
      # Add 'total' array
      totalData = _.find memo, (array) => array[groupBy] == 'total'
      unless totalData
        totalData = []
        totalData.groupBy = groupBy
        totalData[groupBy] = 'total'
        memo.push totalData

      # Add total datum
      total = _.findWhere totalData, { year: budget.get 'year' }
      unless total
        total = { amount: 0, year: budget.get('year') }
        total['groupBy'] = groupBy
        total[groupBy] = 'total'
        total.summary = @modelOrCollection instanceof Backbone.Collection

        unless total.summary
          total.model_id = @modelOrCollection.id
          total.id_type = @modelOrCollection.name
          total.name = @modelOrCollection.toString()

        totalData.push total
      total.amount += budget.get('amount') / (@populations[budget.get('year')] or 1)

    return memo

  filtered: (modelOrCollection) =>
    @modelOrCollection = modelOrCollection
    budgetData = modelOrCollection.selectedBudgetData(Visio.Constants.ANY_YEAR, @filters).models

    normalized = @filters.get('normalized').filter('normalized')

    @populations = {}
    if normalized
      _.each Visio.manager.get('yearList'), (year) =>
        @populations[year] = @modelOrCollection.selectedPopulation year

    _.chain(budgetData).reduce(@reduceFn, [], @).value()

  polygon: (d) ->
    return "M0 0" unless d? and d.length
    "M" + d.join("L") + "Z"

  select: (e, d, i) =>
    line = @g.select(".budget-line-#{d[d.groupBy]}")
    isActive = line.classed 'active'
    line.classed 'active', not isActive

  onMouseenterVoronoi: (d, filtered) =>
    pointData = _.chain(filtered).flatten().where({ year: d.point.year }).value()
    points = @g.selectAll('.point').data pointData
    points.enter().append 'circle'
    points
      .attr('r', 5)
      .attr('class', (d) -> ['point', Visio.Utils.stringToCssClass(d[d.groupBy])].join(' '))
    points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    points.exit().remove()


    if @tooltip?
      @tooltip.year = d.point.year
      @tooltip.collection = new Backbone.Collection(pointData)
      @tooltip.render(true)
    else
      @tooltip = new Visio.Views.BmyTooltip
        figure: @
        year: d.point.year
        collection: new Backbone.Collection(pointData)
      @tooltip.render()

  onMouseclickVoronoi: (d, filtered) =>

    if @selectedDatum.get('d') == d.point
      @renderSelectedComponents null, []
    else
      pointData = _.chain(filtered).flatten().where({ year: d.point.year }).value()
      @renderSelectedComponents d.point, pointData

  # Renders shapes for when you select a certain year to view the narrative
  renderSelectedComponents: (point, pointData) =>
    @selectedDatum.set 'd', point

    pointLineData = if @selectedDatum.get('d')? then [point.year] else []
    pointLine = @g.selectAll('.budget-point-line').data pointLineData
    pointLine.enter().append 'line'
    pointLine.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('class', 'budget-point-line')
      .attr('x1', (d) => @x(d))
      .attr('x2', (d) => @x(d))
      .attr('y1', (d) => 0)
      .attr('y2', (d) => @adjustedHeight)
    pointLine.exit().remove()

    pointShadows = @g.selectAll('.budget-point-shadow-selected').data pointData
    pointShadows.enter().append 'circle'
    pointShadows
      .attr('r', 7)
      .attr('class', (d) ->
        ['budget-point-shadow-selected', Visio.Utils.stringToCssClass(d[d.groupBy])].join(' '))
    pointShadows.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    pointShadows.exit().remove()

    points = @g.selectAll('.budget-point-selected').data pointData
    points.enter().append 'circle'
    points
      .attr('r', 5)
      .attr('class', (d) ->
        ['budget-point-selected', Visio.Utils.stringToCssClass(d[d.groupBy])].join(' '))
    points.transition().duration(Visio.Durations.VERY_FAST).ease('ease-in')
      .attr('cx', (d) => @x(d.year))
      .attr('cy', (d) => @y(d.amount))
    points.exit().remove()

  yAxisLabel: ->
    normalized = @filters.get('normalized').filter 'normalized'
    title = if normalized then 'Budget Per Beneficiary' else 'Budget'

    return @templateLabel
        title: title,
        subtitles: ['in US Dollars']


  close: =>
    super
    @tooltip?.close()
