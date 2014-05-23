# Budget Multiple Year
class Visio.Figures.Bmy extends Visio.Figures.Base

  @include Visio.Mixins.Exportable

  type: Visio.FigureTypes.BMY

  groupBy: 'budget_type'

  initialize: (config) ->
    values = {}
    values[Visio.Scenarios.AOL] = false
    values[Visio.Scenarios.OL] = true

    groupByValues = {}

    groupByValues['scenario'] = false
    groupByValues['budget_type'] = false
    groupByValues['pillar'] = false
    groupByValues[@groupBy] = true

    @filters = new Visio.Collections.FigureFilter([
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
          @render()
      },
      {
        id: 'budget_type'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Budgets), _.values(Visio.Budgets).map(-> true))
      },
      {
        id: 'pillar'
        filterType: 'checkbox'
        values: _.object(_.values(Visio.Pillars), _.values(Visio.Pillars).map(-> true))
      },
      {
        id: 'scenario'
        filterType: 'checkbox'
        values: values
      }
    ])

    super config

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
      .clipExtent([[-@margin.left, -@margin.top], [@adjustedWidth + @margin.right, @adjustedHeight + @margin.bottom]])

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
      .tickFormat(Visio.Formats.MONEY)
      .innerTickSize(14)
      .tickPadding(20)

    @g.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(0,0)')
      .append("text")

    @g.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@adjustedHeight})")
      .append("text")



  render: ->
    filtered = @filtered @collection
    @y.domain [0, d3.max(_.flatten(filtered), (d) -> d.amount)]

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

    # For selecting line segments

    voronoi = @g.selectAll('.voronoi').data(@voronoiFn(_.flatten(filtered)))
    voronoi.enter().append('path')
    voronoi.attr('class', (d, i) -> 'voronoi')
      .attr('d', @polygon)
      .on('mouseenter', (d) => @onMouseenterVoronoi(d, filtered) )

    if @isExport
      voronoi.on('click', (d, i) =>
        # ASSUMES DETERMINISTIC FLATTEN FUNCTION
        count = 0
        lineIndex = null
        _.each filtered, (lineArray, lineArrayIndex) ->
          _.each lineArray, (lineDatum) ->
            lineIndex = lineArrayIndex if count == i
            count += 1

        $.publish "select.#{@figureId()}", [d.point, lineIndex])

    voronoi.exit().remove()

    @g.select('.x.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@xAxis)

    @g.select('.y.axis')
      .transition()
      .duration(Visio.Durations.FAST)
      .call(@yAxis)
      .attr('transform', 'translate(-20,0)')

    @

  # Transforms parameter into data for the BMY graph
  # Data structure:
  # [ [ { amount: xxx, groupby: <group>, year: 2012 }, { .. year: 2013 }, ... ] ... ]
  reduceFn: (memo, budget) =>
    unless budget.get('year')
      console.warn 'No year for budget: ' + budget.id
      return memo

    return memo if @filters.isFiltered budget

    # Add groupBy array
    lineData = _.find memo, (array) => array[@groupBy] == budget.get @groupBy
    unless lineData
      lineData = []
      lineData['groupBy'] = @groupBy
      lineData[@groupBy] = budget.get @groupBy
      memo.push lineData unless @filters.isFiltered budget


    # Add line datum
    datum = _.findWhere lineData, { year: budget.get 'year' }
    unless datum
      datum = { amount: 0, year: budget.get('year') }
      datum['groupBy'] = @groupBy
      datum[@groupBy] = budget.get @groupBy
      lineData.push datum unless @filters.isFiltered budget

    datum.amount += budget.get 'amount'

    if @filters.get('show_total').filter('Show Total')
      # Add 'total' array
      totalData = _.find memo, (array) => array[@groupBy] == 'total'
      unless totalData
        totalData = []
        totalData.groupBy = @groupBy
        totalData[@groupBy] = 'total'
        memo.push totalData

      # Add total datum
      total = _.findWhere totalData, { year: budget.get 'year' }
      unless total
        total = { amount: 0, year: budget.get('year') }
        total['groupBy'] = @groupBy
        total[@groupBy] = 'total'
        totalData.push total
      total.amount += budget.get 'amount'

    return memo

  filtered: (collection) =>
    _.chain(collection.models).reduce(@reduceFn, []).value()

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


